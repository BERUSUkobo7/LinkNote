import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class TagManagementScreen extends StatelessWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          final allTags =
              todoProvider.todos.expand((todo) => todo.tags).toSet().toList();

          if (allTags.isEmpty) {
            return const Center(
              child: Text('No tags found.'),
            );
          }

          return ListView.builder(
            itemCount: allTags.length,
            itemBuilder: (context, index) {
              final tag = allTags[index];
              return ListTile(
                title: Text(tag),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Tag'),
                        content: Text(
                            'Are you sure you want to delete the tag "$tag"? This will remove it from all associated todos.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              todoProvider.deleteTag(tag);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
  }
}
