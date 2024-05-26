class FundHistory {
  final String historyId;
  final String projectId;
  final List<String> pledgers;

  FundHistory({
    required this.historyId,
    required this.projectId,
    required this.pledgers,
  });

  factory FundHistory.fromMap(Map<String, dynamic> map) {
    return FundHistory(
      historyId: map['historyId'],
      projectId: map['projectId'],
      pledgers: List<String>.from(map['pledgers']),
    );
  }

  FundHistory copyWith({
    String? historyId,
    String? projectId,
    List<String>? pledgers,
  }) {
    return FundHistory(
      historyId: historyId ?? this.historyId,
      projectId: projectId ?? this.projectId,
      pledgers: pledgers ?? List<String>.from(this.pledgers),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'historyId': historyId,
      'projectId': projectId,
      'pledgers': pledgers,
    };
  }
}
