import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'add_edit_todo_screen.dart';
import 'tag_management_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  String? _selectedTag;
  final Set<String> _expandedMemoIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              final allTags = todoProvider.todos
                  .expand((todo) => todo.tags)
                  .toSet()
                  .toList();
              if (allTags.isEmpty) {
                return Container();
              }
              return PopupMenuButton<String>(
                onSelected: (tag) {
                  setState(() {
                    _selectedTag = tag == 'all' ? null : tag;
                  });
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('All'),
                    ),
                    ...allTags.map((tag) => PopupMenuItem(
                          value: tag,
                          child: Text(tag),
                        )),
                  ];
                },
                icon: const Icon(Icons.filter_list),
              );
            },
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          final todos = _selectedTag == null
              ? todoProvider.todos
              : todoProvider.todos
                  .where((todo) => todo.tags.contains(_selectedTag))
                  .toList();

          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.all(8),
            itemCount: todos.length,
            onReorder: (oldIndex, newIndex) {
              todoProvider.reorderTodo(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final todo = todos[index];
              final isExpanded = _expandedMemoIds.contains(todo.id);
              final hasMemo = todo.memo != null && todo.memo!.isNotEmpty;
              final hasUrl = todo.url != null && todo.url!.isNotEmpty;

              return Card(
                key: ValueKey(todo.id),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Dismissible(
                  key: ValueKey('${todo.id}_dismissible'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Todo'),
                          content: const Text(
                              'Are you sure you want to delete this todo?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                todoProvider.deleteTodo(todo.id);
                                Navigator.of(context).pop(true);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditTodoScreen(todo: todo),
                        ),
                      );
                      return false;
                    }
                  },
                  child: ListTile(
                    isThreeLine:
                        todo.tags.isNotEmpty || (isExpanded && hasMemo),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    title: Text(
                      todo.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todo.tags.isNotEmpty)
                          Wrap(
                            spacing: 8.0,
                            children: todo.tags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      labelStyle: const TextStyle(fontSize: 12),
                                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
                                    ))
                                .toList(),
                          ),
                        if (isExpanded && hasMemo)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(todo.memo!),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.link),
                          color: hasUrl ? null : Colors.grey,
                          onPressed: hasUrl
                              ? () async {
                                  final url = todo.url!;
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Could not launch $url'),
                                      ),
                                    );
                                  }
                                }
                              : null,
                        ),
                        IconButton(
                          icon: Icon(isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                          color: hasMemo ? null : Colors.grey,
                          onPressed: hasMemo
                              ? () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedMemoIds.remove(todo.id);
                                    } else {
                                      _expandedMemoIds.add(todo.id);
                                    }
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Text(
                '#',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TagManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditTodoScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Removed to move FAB to default bottom-right
    );
  }
}
