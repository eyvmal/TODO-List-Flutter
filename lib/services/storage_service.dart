import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/models/task.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Task>> loadTasks() async {
    await init();
    String? tasksJson = _prefs?.getString('tasks');
    if (tasksJson != null) {
      Iterable decoded = jsonDecode(tasksJson);
      return List<Task>.from(decoded.map((task) => Task.fromJson(task)));
    }
    return [];
  }

  Future<void> saveTasks(List<Task> tasks) async {
    await init();
    String encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await _prefs?.setString('tasks', encoded);
  }
}
