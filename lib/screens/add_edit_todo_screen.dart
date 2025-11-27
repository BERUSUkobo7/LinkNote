import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;

  const AddEditTodoScreen({super.key, this.todo});

  @override
  _AddEditTodoScreenState createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String? _url;
  late String _tags;
  late Color _color;
  late String? _memo;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = widget.todo?.name ?? '';
    _url = widget.todo?.url;
    _tags = widget.todo?.tags.join(', ') ?? '';
    _color = widget.todo?.colorValue != null
        ? Color(widget.todo!.colorValue!)
        : Colors.transparent;
    _memo = widget.todo?.memo;
    _tagController.text = _tags;
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final allTags =
        todoProvider.todos.expand((todo) => todo.tags).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Todo' : 'Edit Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (widget.todo == null) {
                  todoProvider.addTodo(
                      _name, _url, _tags, _color.value, _memo);
                } else {
                  todoProvider.editTodo(widget.todo!.id, _name, _url, _tags,
                      _color.value, _memo);
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _url,
                decoration: const InputDecoration(labelText: 'URL'),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final urlPattern =
                        r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';
                    if (!RegExp(urlPattern).hasMatch(value)) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
                onSaved: (value) => _url = value,
              ),
              TextFormField(
                controller: _tagController,
                decoration:
                    const InputDecoration(labelText: 'Tags (comma separated)'),
                onSaved: (value) => _tags = value!,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: allTags
                    .map((tag) => ActionChip(
                          label: Text(tag),
                          onPressed: () {
                            setState(() {
                              final currentTags = _tagController.text
                                  .split(',')
                                  .map((t) => t.trim())
                                  .where((t) => t.isNotEmpty)
                                  .toList();
                              if (!currentTags.contains(tag)) {
                                currentTags.add(tag);
                                _tagController.text = currentTags.join(', ');
                              }
                            });
                          },
                        ))
                    .toList(),
              ),
              TextFormField(
                initialValue: _memo,
                decoration: const InputDecoration(labelText: 'Memo'),
                maxLines: 5,
                onSaved: (value) => _memo = value,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Color:'),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Pick a color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: _color,
                              onColorChanged: (color) {
                                setState(() {
                                  _color = color;
                                });
                              },
                              showLabel: true,
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Done'),
                            )
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
