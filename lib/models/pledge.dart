class Pledge {
  final String pledgeId;
  final String userId;
  final String projectId;
  final double amount;
  final DateTime date;
  final String status;

  Pledge({
    required this.pledgeId,
    required this.userId,
    required this.projectId,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory Pledge.fromMap(Map<String, dynamic> map) {
    return Pledge(
      pledgeId: map['pledgeId'],
      userId: map['userId'],
      projectId: map['projectId'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      status: map['status'],
    );
  }

  Pledge copyWith({
    String? pledgeId,
    String? userId,
    String? projectId,
    double? amount,
    DateTime? date,
    String? status,
  }) {
    return Pledge(
      pledgeId: pledgeId ?? this.pledgeId,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pledgeId': pledgeId,
      'userId': userId,
      'projectId': projectId,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
