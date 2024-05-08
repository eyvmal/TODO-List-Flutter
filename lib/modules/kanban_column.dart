import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/providers/task_provider.dart';

class KanbanColumn extends StatefulWidget {
  final String title;
  final Color color;
  final int columnId;
  final double maxWidth;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.color,
    required this.columnId,
    this.maxWidth = 300.0,
  });

  @override
  KanbanColumnState createState() => KanbanColumnState();
}

class KanbanColumnState extends State<KanbanColumn> {
  late TextEditingController controller;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = Provider.of<TaskProvider>(context)
        .tasks
        .where((task) => task.column == widget.columnId.toString())
        .toList();

    return Flexible(
      flex: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length + (widget.columnId == 0 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (widget.columnId == 0 && index == tasks.length) {
                      return _buildTaskInput();
                    }
                    return _buildTaskTile(tasks[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: darken(widget.color, 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Text(task.title, style: const TextStyle(color: Colors.black)),
        onTap: () =>
            Provider.of<TaskProvider>(context, listen: false).moveTask(task.id),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            switch (value) {
              case 'edit':
                _editTask(task);
                break;
              case 'delete':
                Provider.of<TaskProvider>(context, listen: false)
                    .deleteTask(task.id, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(Task task) {
    TextEditingController editController =
        TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(
            controller: editController,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  Provider.of<TaskProvider>(context, listen: false)
                      .editTask(task.id, editController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskInput() {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Type a new task',
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white24,
      ),
      style: const TextStyle(color: Colors.black),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          Provider.of<TaskProvider>(context, listen: false)
              .addTask(value, widget.columnId);
          controller.clear();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (focusNode.canRequestFocus) {
              focusNode.requestFocus();
            }
          });
        }
      },
    );
  }

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
