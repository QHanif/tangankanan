import 'package:flutter/foundation.dart';

class Update extends ChangeNotifier {
  final String updateId;
  final String projectId;
  final String title;
  final String description;
  final DateTime date;

  Update({
    required this.updateId,
    required this.projectId,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Update.fromMap(Map<String, dynamic> map) {
    return Update(
      updateId: map['updateId'],
      projectId: map['projectId'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }

  Update copyWith({
    String? updateId,
    String? projectId,
    String? title,
    String? description,
    DateTime? date,
  }) {
    return Update(
      updateId: updateId ?? this.updateId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'updateId': updateId,
      'projectId': projectId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
