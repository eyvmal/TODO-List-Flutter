import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todolist/providers/task_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late String currentDate;
  int tasksCompletedToday = 0;
  bool isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    currentDate = DateFormat('yMMMMd').format(DateTime.now());
    _loadOrPromptProjectName();
    _controller = TextEditingController(text: "New Project");
    Provider.of<TaskProvider>(context, listen: false)
        .addListener(_updateTaskCompletion);
  }

  @override
  void dispose() {
    _controller.dispose();
    Provider.of<TaskProvider>(context, listen: false)
        .removeListener(_updateTaskCompletion);
    super.dispose();
  }

  void _updateTaskCompletion() {
    String todayDate = DateFormat('yMMMMd').format(DateTime.now());
    var provider = Provider.of<TaskProvider>(context, listen: false);
    tasksCompletedToday = provider.tasks
        .where((task) => task.column == '2' && task.completionDate == todayDate)
        .length;
    setState(() {});
  }

  Future<void> _loadOrPromptProjectName() async {
    final prefs = await SharedPreferences.getInstance();
    var name = prefs.getString('projectName');
    if (name == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _promptProjectName();
      });
    } else {
      setState(() {
        _controller.text = name;
      });
    }
  }

  Future<void> _saveProjectName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('projectName', name);
    setState(() {
      _controller.text = name;
    });
  }

  Future<void> _promptProjectName() async {
    TextEditingController controller = TextEditingController(
        text: _controller.text != "New Project" ? _controller.text : "");

    String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Project Name'),
          content: TextField(
            autofocus: true,
            controller: controller,
            decoration:
                const InputDecoration(hintText: 'Type your project name here'),
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (name != null && name.isNotEmpty) {
      await _saveProjectName(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(currentDate,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          SizedBox(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _controller.text, // Display the project name
                  style: const TextStyle(
                      fontSize: 50, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _promptProjectName(); // Call to open the dialog for editing
                  },
                  tooltip: 'Edit Project Name',
                ),
              ],
            ),
          ),
          const Text('Tasks Completed Today',
              style: TextStyle(fontSize: 16, color: Colors.black54)),
          Text('$tasksCompletedToday',
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
