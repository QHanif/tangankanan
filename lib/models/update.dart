import 'package:flutter/foundation.dart';

class Update extends ChangeNotifier {
  final String updateId;
  final String projectId;
  final String title;
  final String description;
  final DateTime date;
  String? imageUrl; // Added this line

  Update({
    required this.updateId,
    required this.projectId,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl, // Added this line
  });

  factory Update.fromMap(Map<String, dynamic> map) {
    return Update(
      updateId: map['updateId'],
      projectId: map['projectId'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      imageUrl: map['imageUrl'], // Added this line
    );
  }

  Update copyWith({
    String? updateId,
    String? projectId,
    String? title,
    String? description,
    DateTime? date,
    String? imageUrl, // Added this line
  }) {
    return Update(
      updateId: updateId ?? this.updateId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl, // Added this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'updateId': updateId,
      'projectId': projectId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl, // Added this line
    };
  }
}
