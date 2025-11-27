import 'dart:convert';

class Todo {
  final String id;
  String name;
  String? url;
  List<String> tags;
  int orderIndex;
  final DateTime createdAt;
  DateTime updatedAt;
  int? colorValue;
  String? memo;

  Todo({
    required this.id,
    required this.name,
    this.url,
    this.tags = const [],
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
    this.colorValue,
    this.memo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'tags': tags,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'colorValue': colorValue,
      'memo': memo,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      tags: List<String>.from(map['tags']),
      orderIndex: map['orderIndex'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      colorValue: map['colorValue'],
      memo: map['memo'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) => Todo.fromMap(json.decode(source));
}
