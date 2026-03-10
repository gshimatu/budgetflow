import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.category,
  });

  final String title;
  final String amount;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(category),
        trailing: Text(amount),
      ),
    );
  }
}
