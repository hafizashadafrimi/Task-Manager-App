import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../service/api_caller.dart';
import '../utils/task_refresh_bus.dart';
import '../utils/urls.dart';
import '../widgets/task_card.dart';
import '../widgets/task_state_view.dart';

class CompletedTaskScreen extends StatefulWidget {
  const CompletedTaskScreen({super.key});
  @override
  State<CompletedTaskScreen> createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState extends State<CompletedTaskScreen> {
  List<TaskModel> taskList = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    TaskRefreshBus.instance.addListener(_onTasksChanged);
    _load();
  }

  @override
  void dispose() {
    TaskRefreshBus.instance.removeListener(_onTasksChanged);
    super.dispose();
  }

  void _onTasksChanged() => _load(showLoader: false);

  Future<void> _load({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }
    final response = await ApiCaller.getRequest(
      url: Urls.taskListByStatusURL('Completed'),
    );
    final list = <TaskModel>[];
    final data = response.responseData is Map
        ? (response.responseData as Map)['data']
        : null;
    if (response.isSuccess && data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(TaskModel.fromJson(item));
        } else if (item is Map) {
          list.add(TaskModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    if (!mounted) return;
    setState(() {
      taskList = response.isSuccess ? list : taskList;
      errorMessage = response.isSuccess
          ? null
          : response.errorMessage ?? 'Unable to load tasks.';
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) {
      return TaskStateView(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load tasks',
        message: errorMessage!,
        onRetry: _load,
      );
    }
    if (taskList.isEmpty) {
      return const TaskStateView(
        icon: Icons.check_circle_outline_rounded,
        title: 'Completed tasks',
        message: 'No completed tasks yet.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: taskList.length,
      itemBuilder: (context, index) => TaskCard(
        taskModel: taskList[index],
        cardColor: const Color(0xFF16A34A),
        refreshParent: () => _load(showLoader: false),
      ),
    );
  }
}
