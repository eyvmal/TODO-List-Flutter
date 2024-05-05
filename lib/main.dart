import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String? projectName; // Local state to hold project name

  @override
  void initState() {
    super.initState();
    _loadProjectName();
  }

  void _updateProjectName(String newName) {
    setState(() {
      projectName = newName;
    });
  }

  Future<void> _loadProjectName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('projectName');
    if (storedName != null) {
      setState(() {
        projectName = storedName;
      });
    }
  }

  Future<void> _promptProjectName(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Project Name'),
          content: TextField(
            autofocus: true,
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Type your project name here',
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(
                  value); // This will close the dialog and return the value
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller
                    .text); // This will also close the dialog and return the text
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (name != null && name.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('projectName', name);
      setState(() {
        projectName = name; // Update local state with the new project name
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      home: projectName == null
          ? FutureBuilder<String?>(
              future: SharedPreferences.getInstance()
                  .then((prefs) => prefs.getString('projectName')),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If no data is found, prompt for project name
                  if (!snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _promptProjectName(context);
                    });
                  }
                  // Use snapshot data or default project name if null
                  return buildHomePage(snapshot.data ?? 'Default Project');
                } else {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            )
          : buildHomePage(projectName!),
    );
  }

  Widget buildHomePage(String projectName) {
    return Scaffold(
      body: Column(
        children: [
          Header(
              projectName: projectName,
              onUpdate: _updateProjectName), // This uses the local state
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KanbanColumn(
                    title: 'To Do', color: Colors.lightBlueAccent, columnId: 0),
                KanbanColumn(
                    title: 'In Progress',
                    color: Colors.amberAccent,
                    columnId: 1),
                KanbanColumn(
                    title: 'Done', color: Colors.greenAccent, columnId: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
