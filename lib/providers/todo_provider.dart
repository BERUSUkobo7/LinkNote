import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import 'package:uuid/uuid.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  static const _todosKey = 'todos';
  String? _selectedTag;

  List<Todo> get todos => _todos;
  String? get selectedTag => _selectedTag;

  List<Todo> get filteredTodos {
    if (_selectedTag == null) {
      return _todos;
    }
    return _todos.where((todo) => todo.tags.contains(_selectedTag)).toList();
  }

  TodoProvider() {
    loadTodos();
  }

  void setSelectedTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = _todos.map((todo) => todo.toJson()).toList();
    await prefs.setStringList(_todosKey, todosJson);
  }

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList(_todosKey);
    if (todosJson != null) {
      _todos = todosJson.map((json) => Todo.fromJson(json)).toList();
      notifyListeners();
    }
  }

  void addTodo(String name, String? url, String tags, int? colorValue, String? memo) {
    final newTodo = Todo(
      id: const Uuid().v4(),
      name: name,
      url: url,
      tags: tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
      orderIndex: _todos.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      colorValue: colorValue,
      memo: memo,
    );
    _todos.add(newTodo);
    _saveTodos();
    notifyListeners();
  }

  void editTodo(String id, String name, String? url, String tags, int? colorValue, String? memo) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex].name = name;
      _todos[todoIndex].url = url;
      _todos[todoIndex].tags = tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
      _todos[todoIndex].updatedAt = DateTime.now();
      _todos[todoIndex].colorValue = colorValue;
      _todos[todoIndex].memo = memo;
      _saveTodos();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    _saveTodos();
    notifyListeners();
  }

  void reorderTodo(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    for (int i = 0; i < _todos.length; i++) {
      _todos[i].orderIndex = i;
    }
    _saveTodos();
    notifyListeners();
  }

  void deleteTag(String tag) {
    for (final todo in _todos) {
      todo.tags.remove(tag);
    }
    _saveTodos();
    notifyListeners();
  }
}
