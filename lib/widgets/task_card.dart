import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../service/api_caller.dart';
import '../theme/theme_data.dart';
import '../utils/task_refresh_bus.dart';
import '../utils/urls.dart';

class TaskCard extends StatefulWidget {
  final TaskModel taskModel;
  final Color cardColor;
  final Future<void> Function() refreshParent;

  const TaskCard({
    super.key,
    required this.taskModel,
    required this.cardColor,
    required this.refreshParent,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _updating = false;
  bool _descriptionExpanded = false;

  Future<void> _delete() async {
    if (_updating) return;
    setState(() => _updating = true);
    final response = await ApiCaller.getRequest(
      url: Urls.deleteTaskURL(widget.taskModel.sId ?? ''),
    );
    if (!mounted) return;
    setState(() => _updating = false);

    if (response.isSuccess) {
      TaskRefreshBus.instance.notifyTasksChanged();
      await widget.refreshParent();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.errorMessage ?? 'Unable to delete task'),
        ),
      );
    }
  }

  Future<void> _status(String status) async {
    if (_updating || widget.taskModel.status == status) return;
    Navigator.of(context).pop();
    setState(() => _updating = true);

    final response = await ApiCaller.getRequest(
      url: Urls.updateTaskStatusURL(widget.taskModel.sId ?? '', status),
    );
    if (!mounted) return;
    setState(() => _updating = false);

    if (response.isSuccess) {
      // One signal refreshes every mounted tab in the IndexedStack.
      TaskRefreshBus.instance.notifyTasksChanged();
      await widget.refreshParent();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Task moved to $status')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.errorMessage ?? 'Unable to update task'),
        ),
      );
    }
  }

  void _actions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        // The action list can be taller than a small browser/mobile viewport.
        // Constrain the sheet and make its contents scroll instead of allowing
        // the Column to overflow at the bottom.
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.82;

        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Text(
                        'Move task',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  for (final status in const [
                    'New',
                    'Progress',
                    'Completed',
                    'Cancelled',
                  ])
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: Icon(
                        widget.taskModel.status == status
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: kPrimary,
                      ),
                      title: Text(status),
                      enabled: !_updating && widget.taskModel.status != status,
                      onTap: () => _status(status),
                    ),
                  const Divider(height: 28),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Delete task',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _updating
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            _delete();
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  DateTime? get _createdAt {
    final raw = widget.taskModel.createdDate;
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  String get _formattedDate {
    final date = _createdAt;
    if (date == null) return 'Date unavailable';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String get _formattedTime {
    final date = _createdAt;
    if (date == null) return '';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.taskModel.status ?? '';
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: _updating ? .55 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EEF4)),
        ),
        child: Row(
          // IMPORTANT: do not use a stretching cross-axis in a ListView.
          // A sliver gives this child an unbounded height, which caused the
          // "BoxConstraints forces an infinite height" exception.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 88,
              decoration: BoxDecoration(
                color: widget.cardColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.taskModel.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (_updating)
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        IconButton(
                          tooltip: 'Task options',
                          onPressed: _actions,
                          icon: const Icon(Icons.more_horiz_rounded),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _ExpandableDescription(
                    text: widget.taskModel.description ?? '',
                    expanded: _descriptionExpanded,
                    onToggle: () {
                      setState(() {
                        _descriptionExpanded = !_descriptionExpanded;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChip(text: status, color: widget.cardColor),
                      _MetaChip(
                        icon: Icons.calendar_today_outlined,
                        text: _formattedDate,
                      ),
                      if (_formattedTime.isNotEmpty)
                        _MetaChip(
                          icon: Icons.schedule_rounded,
                          text: _formattedTime,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableDescription extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _ExpandableDescription({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final description = text.trim();
    if (description.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final style =
            Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45) ??
            const TextStyle(fontSize: 14, height: 1.45);

        final painter = TextPainter(
          text: TextSpan(text: description, style: style),
          textDirection: Directionality.of(context),
          maxLines: 3,
        )..layout(maxWidth: constraints.maxWidth);

        final hasMore = painter.didExceedMaxLines;

        return AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                maxLines: expanded ? null : 3,
                overflow: expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: style,
              ),
              if (hasMore) ...[
                const SizedBox(height: 6),
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          expanded ? 'Show less' : 'More text',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 17,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
    ),
  );
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    ),
  );
}
