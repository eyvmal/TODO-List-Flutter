import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final StorageService _storageService = StorageService();

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _tasks = await _storageService.loadTasks();
    notifyListeners();
  }

  List<Task> get tasks => _tasks;

  void addTask(String title, int columnId) {
    _tasks.add(Task(
        id: UniqueKey().toString(), title: title, column: columnId.toString()));
    saveTasks();
  }

  void moveTask(String taskId) {
    Task task = _tasks.firstWhere((task) => task.id == taskId);
    int currentColumn = int.parse(task.column);
    int nextColumn = currentColumn + 1;

    if (nextColumn <= 2) {
      task.column = nextColumn.toString();
      if (nextColumn == 2) {
        task.completionDate = DateFormat('yMMMMd').format(DateTime.now());
      }
      saveTasks();
      notifyListeners();
    }
  }

  void moveTaskBack(String taskId, context) {
    Task task = _tasks.firstWhere((task) => task.id == taskId);
    int currentColumn = int.parse(task.column);
    int prevColumn = currentColumn - 1;

    if (prevColumn >= 0) {
      task.column = prevColumn.toString();
      if (currentColumn == 2) {
        task.completionDate = null;
      }
      saveTasks();
      notifyListeners();
    } else {
      deleteTask(taskId, context);
    }
  }

  void deleteTask(String taskId, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are You Sure?"),
          content: const Text("This will delete the task permanently."),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _tasks.removeWhere((t) => t.id == taskId);
                saveTasks();
                notifyListeners();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void saveTasks() async {
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }
}
