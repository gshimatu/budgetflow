import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';
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

  Stream<List<CategoryModel>> watchGlobalCategories() {
    return _db
        .collection('globalCategories')
        .orderBy('order', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<CategoryModel>> watchUserCategories(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('userCategories')
        .orderBy('order', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addUserCategory(String uid, CategoryModel category) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('userCategories')
        .add(category.toMap());
  }

  Future<void> ensureDefaultGlobalCategories() async {
    final existing = await _db.collection('globalCategories').limit(1).get();
    if (existing.docs.isNotEmpty) {
      return;
    }

    final defaults = [
      {'name': 'Transport', 'type': 'expense'},
      {'name': 'Nourriture', 'type': 'expense'},
      {'name': 'Logement', 'type': 'expense'},
      {'name': 'Santé', 'type': 'expense'},
      {'name': 'Éducation', 'type': 'expense'},
      {'name': 'Loisirs', 'type': 'expense'},
      {'name': 'Factures', 'type': 'expense'},
      {'name': 'Shopping', 'type': 'expense'},
      {'name': 'Épargne', 'type': 'expense'},
      {'name': 'Voyage', 'type': 'expense'},
      {'name': 'Télécom', 'type': 'expense'},
      {'name': 'Salaire', 'type': 'income'},
    ];

    final batch = _db.batch();
    for (var i = 0; i < defaults.length; i++) {
      final item = defaults[i];
      final docRef = _db.collection('globalCategories').doc();
      batch.set(docRef, {
        'name': item['name'],
        'type': item['type'],
        'order': i,
      });
    }
    await batch.commit();
  }
}
