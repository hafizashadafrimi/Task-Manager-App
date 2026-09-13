import 'package:flutter/foundation.dart';

/// A small app-wide signal used to keep all task tabs in sync.
/// Any create, delete or status update notifies every task screen.
class TaskRefreshBus extends ChangeNotifier {
  TaskRefreshBus._();

  static final TaskRefreshBus instance = TaskRefreshBus._();

  int _revision = 0;
  int get revision => _revision;

  void notifyTasksChanged() {
    _revision++;
    notifyListeners();
  }
}
