class HistoryItem {
  final String id;
  final String companyName;
  final String accountType;
  final DateTime date;
  final Map<String, dynamic> calculationData;
  final DateTime createdAt;

  HistoryItem({
    required this.id,
    required this.companyName,
    required this.accountType,
    required this.date,
    required this.calculationData,
    required this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      companyName: json['companyName'],
      accountType: json['accountType'],
      date: DateTime.parse(json['date']),
      calculationData: json['calculationData'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'accountType': accountType,
      'date': date.toIso8601String(),
      'calculationData': calculationData,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
