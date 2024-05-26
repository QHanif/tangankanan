class Project {
  final String projectId;
  final String creatorId;
  final String title;
  final String description;
  final String projectPicUrl;
  final double fundGoal;
  final double currentFund;
  final DateTime startDate;
  final DateTime endDate;
  final String verificationStatus;
  final List<String> backers;
  final List<String> updates;
  final String projectStatus;

  Project({
    required this.projectId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.projectPicUrl,
    required this.fundGoal,
    required this.currentFund,
    required this.startDate,
    required this.endDate,
    required this.verificationStatus,
    required this.backers,
    required this.updates,
    required this.projectStatus,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      projectId: map['projectId'],
      creatorId: map['creatorId'],
      title: map['title'],
      description: map['description'],
      projectPicUrl: map['projectPicUrl'],
      fundGoal: map['fundGoal'],
      currentFund: map['currentFund'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      verificationStatus: map['verificationStatus'],
      backers: List<String>.from(map['backers']),
      updates: List<String>.from(map['updates']),
      projectStatus: map['projectStatus'],
    );
  }

  Project copyWith({
    String? projectId,
    String? creatorId,
    String? title,
    String? description,
    String? projectPicUrl,
    double? fundGoal,
    double? currentFund,
    DateTime? startDate,
    DateTime? endDate,
    String? verificationStatus,
    List<String>? backers,
    List<String>? updates,
    String? projectStatus,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      projectPicUrl: projectPicUrl ?? this.projectPicUrl,
      fundGoal: fundGoal ?? this.fundGoal,
      currentFund: currentFund ?? this.currentFund,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      backers: backers ?? List<String>.from(this.backers),
      updates: updates ?? List<String>.from(this.updates),
      projectStatus: projectStatus ?? this.projectStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'projectPicUrl': projectPicUrl,
      'fundGoal': fundGoal,
      'currentFund': currentFund,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'verificationStatus': verificationStatus,
      'backers': backers,
      'updates': updates,
      'projectStatus': projectStatus,
    };
  }
}
