import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todolist/providers/task_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatefulWidget {
  final String projectName;
  final Function(String) onUpdate;

  const Header({super.key, required this.projectName, required this.onUpdate});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late String currentDate;
  int tasksCompletedToday = 0;
  bool isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    currentDate = DateFormat('yMMMMd').format(DateTime.now());
    Provider.of<TaskProvider>(context, listen: false)
        .addListener(_updateTaskCompletion);
    _controller = TextEditingController(text: widget.projectName);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    Provider.of<TaskProvider>(context, listen: false)
        .removeListener(_updateTaskCompletion);
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
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

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _saveProjectName(); // Save when focus is lost
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveProjectName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('projectName', _controller.text);
    widget.onUpdate(_controller.text); // Update parent state
    if (isEditing) {
      setState(() {
        isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            currentDate,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(
            height: 75,
            child: isEditing
                ? TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(
                        fontSize: 50, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'Enter project name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    autofocus: true,
                    textAlign: TextAlign.center,
                  )
                : InkWell(
                    onDoubleTap: _toggleEdit,
                    child: Text(
                      widget.projectName,
                      style: const TextStyle(
                          fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
          const Text(
            'Tasks Completed Today',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Text(
            '$tasksCompletedToday',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
