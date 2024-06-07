// issue_model.dart
class Issue {
  final String? id;
  final String drugId;
  final String? userId;
  final DateTime date;
  final int quantity;
  final String key;

  Issue({
    this.id,
    required this.drugId,
    this.userId,
    required this.date,
    required this.quantity,
    required this.key,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      drugId: json['drug_id'],
      userId: json['user_id'],
      date: DateTime.parse(json['tanggal_keluar']),
      quantity: json['quantity'],
      key: json['key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drug_id': drugId,
      'user_id': userId,
      'tanggal_keluar': date.toIso8601String(),
      'quantity': quantity,
      'key': key,
    };
  }
}
