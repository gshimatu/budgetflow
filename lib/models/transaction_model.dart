import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.categoryName,
  });

  final String id;
  final double amount;
  final String type;
  final String categoryId;
  final DateTime date;
  final String? note;
  final String? categoryName;

  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    final rawDate = data['date'];
    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else {
      parsedDate = DateTime.parse(rawDate as String);
    }
    return TransactionModel(
      id: id,
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] as String,
      categoryId: data['categoryId'] as String,
      date: parsedDate,
      note: data['note'] as String?,
      categoryName: data['categoryName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
      'categoryName': categoryName,
    };
  }
}
