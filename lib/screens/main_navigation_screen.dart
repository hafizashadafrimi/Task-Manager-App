import 'package:flutter/material.dart';
import 'package:task_manager_app_assignment/screens/progress_task_screen.dart';
import 'package:task_manager_app_assignment/screens/update_profile_screen.dart';
import '../controller/auth_controller.dart';
import '../theme/theme_data.dart';
import 'add_task_screen.dart';
import 'cancel_task_screen.dart';
import 'completed_task_screen.dart';
import 'new_task_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    NewTaskScreen(),
    ProgressTaskScreen(),
    CompletedTaskScreen(),
    CancelTaskScreen(),
  ];

  final List<String> titles = const [
    'My Tasks',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  Future<void> _openCreateTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddNewTaskScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthController.userData;
    final firstName = user?.firstName?.trim();
    final displayName = (firstName == null || firstName.isEmpty)
        ? 'there'
        : firstName;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 92,
        titleSpacing: 20,
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: kPrimary.withValues(alpha: .12),
              child: const Icon(Icons.person_rounded, color: kPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $displayName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Update profile',
              onPressed: _openProfile,
              icon: const Icon(Icons.manage_accounts_outlined),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                titles[selectedIndex],
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(index: selectedIndex, children: screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              onPressed: _openCreateTask,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New task'),
            )
          : null,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8EEF4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBar(
            height: 72,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: kPrimary.withValues(alpha: .12),
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => selectedIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: kPrimary),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.timelapse_outlined),
                selectedIcon: Icon(Icons.timelapse_rounded, color: kPrimary),
                label: 'Progress',
              ),
              NavigationDestination(
                icon: Icon(Icons.check_circle_outline),
                selectedIcon: Icon(Icons.check_circle_rounded, color: kPrimary),
                label: 'Completed',
              ),
              NavigationDestination(
                icon: Icon(Icons.cancel_outlined),
                selectedIcon: Icon(Icons.cancel_rounded, color: kPrimary),
                label: 'Cancelled',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
