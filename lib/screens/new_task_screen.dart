import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/task_status_count_model.dart';
import '../service/api_caller.dart';
import '../utils/task_refresh_bus.dart';
import '../utils/urls.dart';
import '../widgets/task_card.dart';
import '../widgets/task_count_card.dart';
import '../widgets/task_state_view.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});
  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  static const _statuses = ['New', 'Progress', 'Completed', 'Cancelled'];
  List<TaskStatusCountModel> taskCountByStatus = [];
  List<TaskModel> taskList = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    TaskRefreshBus.instance.addListener(_onTasksChanged);
    _refresh();
  }

  @override
  void dispose() {
    TaskRefreshBus.instance.removeListener(_onTasksChanged);
    super.dispose();
  }

  void _onTasksChanged() {
    _refresh(showLoader: false);
  }

  Future<void> _refresh({bool showLoader = true}) async {
    if (showLoader && mounted) setState(() => loading = true);
    errorMessage = null;

    final results = await Future.wait([
      ApiCaller.getRequest(url: Urls.taskStatusCountURL),
      ApiCaller.getRequest(url: Urls.taskListByStatusURL('New')),
    ]);

    final countResponse = results[0];
    final taskResponse = results[1];
    final counts = <TaskStatusCountModel>[];
    final tasks = <TaskModel>[];

    if (countResponse.isSuccess) {
      final data = countResponse.responseData is Map
          ? countResponse.responseData['data']
          : null;
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            counts.add(TaskStatusCountModel.fromJson(item));
          }
        }
      }
    }

    if (taskResponse.isSuccess) {
      final data = taskResponse.responseData is Map
          ? taskResponse.responseData['data']
          : null;
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) tasks.add(TaskModel.fromJson(item));
        }
      }
    }

    if (!mounted) return;
    setState(() {
      taskCountByStatus = counts;
      taskList = tasks;
      loading = false;
      if (!countResponse.isSuccess && !taskResponse.isSuccess) {
        errorMessage =
            taskResponse.errorMessage ??
            countResponse.errorMessage ??
            'Unable to load your tasks.';
      }
    });
  }

  int _countFor(String status) {
    for (final item in taskCountByStatus) {
      if ((item.sId ?? '').toLowerCase() == status.toLowerCase()) {
        return item.sum ?? 0;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(showLoader: false),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((_, index) {
                final status = _statuses[index];
                return TaskCardCount(title: status, count: _countFor(status));
              }, childCount: _statuses.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 124,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'New tasks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: TaskStateView(
                icon: Icons.cloud_off_rounded,
                title: 'Could not load tasks',
                message: errorMessage!,
                onRetry: () => _refresh(),
              ),
            )
          else if (taskList.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: TaskStateView(
                icon: Icons.task_alt_rounded,
                title: 'No new tasks',
                message: 'Create a task or pull down to refresh.',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, index) => TaskCard(
                  taskModel: taskList[index],
                  cardColor: const Color(0xFF2563EB),
                  refreshParent: () => _refresh(showLoader: false),
                ),
                childCount: taskList.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
