class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
  });

  final String id;
  final double amount;
  final String type;
  final String categoryId;
  final DateTime date;
  final String? note;

  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] as String,
      categoryId: data['categoryId'] as String,
      date: DateTime.parse(data['date'] as String),
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
