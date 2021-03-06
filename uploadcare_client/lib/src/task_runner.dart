import 'dart:async';
import 'dart:collection';

int _internalIdCounter = 0;

typedef TaskAction<T> = Future<T> Function();

class _Task<T> {
  _Task(this._action);

  final int id = ++_internalIdCounter;

  final TaskAction<T> _action;

  late T _result;
  T get result => _result;

  Object? _error;
  Object? get error => _error;

  Future<void> run() async {
    try {
      _result = await _action();
    } catch (e) {
      _error = e;
    }
  }

  @override
  String toString() {
    return '[Task]: $id';
  }
}

class TaskRunner {
  TaskRunner([this._maxConcurrentTasks = 5]);

  final int _maxConcurrentTasks;
  final Queue<_Task> _tasks = Queue();
  final Map<_Task, Completer> _taskCompleters = {};
  final Set<_Task> _inProgress = {};

  bool get hasRunningTasks => _inProgress.isNotEmpty;

  bool get hasScheduledTasks => _tasks.isNotEmpty;

  Future<T> push<T>(TaskAction<T> action) {
    final task = _Task(action);
    final completer = Completer<T>();

    _taskCompleters.putIfAbsent(task, () => completer);
    _onTaskRecieved(task);

    return completer.future;
  }

  void _onTaskRecieved(_Task task) {
    _tasks.addFirst(task);

    if (_inProgress.length < _maxConcurrentTasks) {
      _runTask();
    }
  }

  Future<void> _runTask() async {
    final task = _tasks.removeLast();

    _inProgress.add(task);

    await task.run();

    if (_taskCompleters.containsKey(task)) {
      final completer = _taskCompleters[task]!;

      _taskCompleters.remove(task);

      if (task.error != null) {
        completer.completeError(task.error!);
      } else {
        completer.complete(task.result);
      }
    }

    _inProgress.remove(task);
    _onTaskReleased();
  }

  void _onTaskReleased() {
    if (_tasks.isNotEmpty && _inProgress.length < _maxConcurrentTasks) {
      _runTask();
    }
  }
}
