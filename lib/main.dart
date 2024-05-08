import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/modules/header.dart';
import 'package:todolist/modules/kanban_column.dart';
import 'package:todolist/providers/task_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<TaskProvider>(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const mobileWidthThreshold = 800;
    bool isMobile = screenWidth < mobileWidthThreshold;

    return MaterialApp(
      title: 'Todo List',
      home: Scaffold(
        body: Column(
          children: [
            const Header(),
            Expanded(
              child: isMobile
                  ? const Column(
                      children: [
                        KanbanColumn(
                            title: 'To Do',
                            color: Colors.lightBlueAccent,
                            columnId: 0),
                        KanbanColumn(
                            title: 'In Progress',
                            color: Colors.amberAccent,
                            columnId: 1),
                        KanbanColumn(
                            title: 'Done',
                            color: Colors.greenAccent,
                            columnId: 2),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        KanbanColumn(
                            title: 'To Do',
                            color: Colors.lightBlueAccent,
                            columnId: 0),
                        KanbanColumn(
                            title: 'In Progress',
                            color: Colors.amberAccent,
                            columnId: 1),
                        KanbanColumn(
                            title: 'Done',
                            color: Colors.greenAccent,
                            columnId: 2),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
