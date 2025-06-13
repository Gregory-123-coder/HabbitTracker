import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String priority; // High, Medium, Low
  String status; // Pending, Completed

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.status,
  });
}

class TaskManagerApp extends StatefulWidget {
  @override
  _TaskManagerAppState createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDeadline = DateTime.now();
  String _selectedPriority = 'Medium';

  final List<Task> _tasks = [];

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        deadline: _selectedDeadline,
        priority: _selectedPriority,
        status: 'Pending',
      );

      setState(() {
        _tasks.add(newTask);
      });

      _titleController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    }
  }

  void _toggleTaskStatus(Task task) {
    setState(() {
      task.status = task.status == 'Pending' ? 'Completed' : 'Pending';
    });
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add a New Task"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: ['High', 'Medium', 'Low']
                    .map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDeadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDeadline = pickedDate;
                    });
                  }
                },
                child: Text("Pick Deadline: ${_selectedDeadline.toLocal()}".split(' ')[0]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: _addTask,
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completionRate = _tasks.isEmpty
        ? 0.0
        : (_tasks.where((task) => task.status == 'Completed').length / _tasks.length).toDouble();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        textTheme: GoogleFonts.pacificoTextTheme(),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Habit tracker"),
          backgroundColor: Colors.brown[400],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Task Completion",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: completionRate,
                    backgroundColor: Colors.brown[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                  ),
                  SizedBox(height: 10),
                  Text("${(completionRate * 100).toStringAsFixed(1)}% Completed"),
                ],
              ),
            ),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text("No tasks added yet."))
                  : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    color: task.status == 'Completed' ? Colors.green[100] : Colors.orange[100],
                    child: ListTile(
                      leading: Icon(Icons.pets, color: Colors.brown),
                      title: Text(task.title),
                      subtitle: Text(
                        "${task.description}\nDeadline: ${task.deadline.toLocal()}".split(' ')[0],
                      ),
                      trailing: TextButton(
                        onPressed: () => _toggleTaskStatus(task),
                        child: Text(
                          task.status == 'Completed' ? "Undo" : "Done",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          backgroundColor: Colors.brown,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
