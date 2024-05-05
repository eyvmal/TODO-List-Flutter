import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/providers/task_provider.dart';

class KanbanColumn extends StatefulWidget {
  final String title;
  final Color color;
  final int columnId;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.color,
    required this.columnId,
  });

  @override
  State<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<KanbanColumn> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _needToRefocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.columnId == 0) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _focusListener() {
    if (_needToRefocus && !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = Provider.of<TaskProvider>(context)
        .tasks
        .where((task) => task.column == widget.columnId.toString())
        .toList();

    return Container(
      width: 300,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(8),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...tasks.map((task) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: darken(widget.color, 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text(task.title,
                            style: const TextStyle(color: Colors.black)),
                        onTap: () =>
                            Provider.of<TaskProvider>(context, listen: false)
                                .moveTask(task.id),
                        onLongPress: () =>
                            Provider.of<TaskProvider>(context, listen: false)
                                .moveTaskBack(task.id, context),
                      ),
                    )),
                if (widget.columnId == 0) ...[
                  TextField(
                    focusNode: _focusNode,
                    controller: _controller,
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
                        _controller.clear();
                        _needToRefocus = true;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
