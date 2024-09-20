import 'package:flutter/material.dart';
import 'package:sqflite_user_data/services/database_helper.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  List<Map<String, dynamic>> todos = [];
  bool isEditing = false;
  int? editingTodoId;

  @override
  void initState() {
    super.initState();
    dbHelper.initDatabase().then((_) => _loadTodos());
  }

  Future<void> _loadTodos() async {
    final data = await dbHelper.getAllTodos();
    setState(() {
      todos = data;
    });
  }

  Future<void> _addOrUpdateTodo() async {
    String name = nameController.text;
    String city = cityController.text;

    if (name.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    if (isEditing && editingTodoId != null) {
      await dbHelper.updateTodo(editingTodoId!, {'name': name, 'city': city});
      setState(() {
        isEditing = false;
        editingTodoId = null;
      });
    } else {
      await dbHelper.insertTodo({'name': name, 'city': city});
    }

    nameController.clear();
    cityController.clear();
    _loadTodos();
  }

  void _editTodo(Map<String, dynamic> todo) {
    setState(() {
      isEditing = true;
      editingTodoId = todo['id'];
      nameController.text = todo['name'];
      cityController.text = todo['city'];
    });
  }

  Future<void> _deleteTodoById(int id) async {
    await dbHelper.deleteTodo(id);
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrUpdateTodo,
              child: Text(isEditing ? 'Update Todo' : 'Add Todo'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: todos.isEmpty
                  ? const Center(child: Text('No todos available'))
                  : ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return Card(
                          elevation: 2.0,
                          child: ListTile(
                            title: Text(todo['name']),
                            subtitle: Text('City: ${todo['city']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _editTodo(todo),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        'Are you sure you wan`t to delete?',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              _deleteTodoById(todo['id']);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Yes')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('No'))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
