import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';

class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> watchTransactions(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addTransaction(String uid, TransactionModel transaction) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add(transaction.toMap());
  }
}
