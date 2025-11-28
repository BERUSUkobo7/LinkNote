import 'package:flutter/material.dart';
import 'add_edit_todo_screen.dart';
import 'tag_management_screen.dart';
import 'todo_list_screen.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const TodoListScreen(),
    const TagManagementScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Link Note' : 'Manage Tags'),
        actions: _selectedIndex == 0
            ? [
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
                        todoProvider.setSelectedTag(tag == 'all' ? null : tag);
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
              ]
            : null,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddEditTodoScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Link Note',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tag),
            label: 'Manage Tags',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
