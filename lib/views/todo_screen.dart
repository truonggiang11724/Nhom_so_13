import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../controllers/api_service.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  List<Todo> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    try {
      List<Todo> todos = await _apiService.getTodos();
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Xử lý lỗi, ví dụ hiển thị thông báo
      print('Failed to load todos: $e');
    }
  }

  Future<void> _addTodo() async {
    if (_controller.text.isNotEmpty) {
      Todo newTodo = Todo(
        title: _controller.text,
        completed: false,
      );
      try {
        Todo createdTodo = await _apiService.createTodo(newTodo);
        setState(() {
          _todos.add(createdTodo);
        });
        _controller.clear();
      } catch (e) {
        // Xử lý lỗi, ví dụ hiển thị thông báo
        print('Failed to add todo: $e');
      }
    }
  }

  Future<void> _updateTodoCompletion(Todo todo, bool completed) async {
    Todo updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      completed: completed,
    );
    try {
      await _apiService.updateTodo(updatedTodo);
      setState(() {
        int index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = updatedTodo;
        }
      });
    } catch (e) {
      // Xử lý lỗi
      print('Failed to update todo: $e');
    }
  }

  Future<void> _updateTodoTitle(Todo todo, String newTitle) async {
    Todo updatedTodo = Todo(
      id: todo.id,
      title: newTitle,
      completed: todo.completed,
    );
    try {
      await _apiService.updateTodo(updatedTodo);
      setState(() {
        int index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = updatedTodo;
        }
      });
    } catch (e) {
      // Xử lý lỗi
      print('Failed to update todo: $e');
    }
  }


  Future<void> _deleteTodo(int id) async {
    try {
      await _apiService.deleteTodo(id);
      setState(() {
        _todos.removeWhere((todo) => todo.id == id);
      });
    } catch (e) {
      // Xử lý lỗi
      print('Failed to delete todo: $e');
    }
  }

  void _showEditTodoDialog(Todo todo) {
    final TextEditingController editController = TextEditingController();
    editController.text = todo.title; // Hiển thị tiêu đề hiện tại

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Edit your task'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newTitle = editController.text;
                if (newTitle.isNotEmpty) {
                  _updateTodoTitle(todo, newTitle);
                }
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('To-Do List'),
      ),
      body: Column(
        children: [
          _isLoading
              ? Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return ListTile(
                  title: Text(todo.title),
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: (value) {
                      _updateTodoCompletion(todo, value!);
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTodo(todo.id!),
                  ),
                  onTap: () => _showEditTodoDialog(todo),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Add a new task'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
