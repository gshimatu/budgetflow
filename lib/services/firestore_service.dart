import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> watchUserProfile(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.data() ?? <String, dynamic>{});
  }

  Future<void> ensureUserProfile({
    required String uid,
    String? email,
    String? displayName,
  }) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      // Vérifie que l'utilisateur existant a les préférences
      final data = doc.data() ?? {};
      if (data['preferences'] == null) {
        await _db.collection('users').doc(uid).set({
          'preferences': {
            'weeklyReport': false,
            'notifications': true,
            'monthlyGoal': 0,
          },
        }, SetOptions(merge: true));
      }
      return;
    }
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'preferences': {
        'weeklyReport': false,
        'notifications': true,
        'monthlyGoal': 0,
      },
    });
  }

  Future<void> updateUserPreferences(
    String uid, {
    bool? weeklyReport,
    bool? notifications,
    double? monthlyGoal,
  }) async {
    final updates = <String, dynamic>{};
    if (weeklyReport != null) {
      updates['preferences.weeklyReport'] = weeklyReport;
    }
    if (notifications != null) {
      updates['preferences.notifications'] = notifications;
    }
    if (monthlyGoal != null) {
      updates['preferences.monthlyGoal'] = monthlyGoal;
    }
    if (updates.isEmpty) return;

    // S'assure que l'objet preferences existe
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data()?['preferences'] == null) {
      updates['preferences'] = {
        'weeklyReport': false,
        'notifications': true,
        'monthlyGoal': 0,
      };
    }

    await _db
        .collection('users')
        .doc(uid)
        .set(updates, SetOptions(merge: true));
  }

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

  Future<void> updateTransaction(
    String uid,
    String transactionId,
    TransactionModel transaction,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transactionId)
        .update(transaction.toMap());
  }

  Future<void> resetUserData(String uid) async {
    await _deleteCollection(
      _db.collection('users').doc(uid).collection('transactions'),
    );
    await _deleteCollection(
      _db.collection('users').doc(uid).collection('userCategories'),
    );
    await _db.collection('users').doc(uid).set({
      'preferences': {
        'monthlyGoal': 0,
      },
    }, SetOptions(merge: true));
  }

  Future<void> _deleteCollection(CollectionReference collection) async {
    while (true) {
      final snapshot = await collection.limit(500).get();
      if (snapshot.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> deleteTransaction(String uid, String transactionId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transactionId)
        .delete();
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

  Future<void> addGlobalCategory(CategoryModel category) async {
    await _db.collection('globalCategories').add(category.toMap());
  }

  Future<void> updateGlobalCategory(String id, CategoryModel category) async {
    await _db.collection('globalCategories').doc(id).update(category.toMap());
  }

  Future<void> deleteGlobalCategory(String id) async {
    await _db.collection('globalCategories').doc(id).delete();
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

  Stream<List<Map<String, dynamic>>> watchUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).set({
      'role': role,
    }, SetOptions(merge: true));
  }

  Future<void> deleteUserProfile(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  Future<void> addFeedback({
    required String uid,
    required String type,
    required String message,
    String? email,
  }) async {
    await _db.collection('feedbacks').add({
      'uid': uid,
      'email': email,
      'type': type,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchFeedbacks() {
    return _db
        .collection('feedbacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final usersCount = await _db.collection('users').count().get();
    final transactionsCount = await _db
        .collectionGroup('transactions')
        .count()
        .get();

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> expenseByCategory = {};
    final txSnapshot = await _db.collectionGroup('transactions').get();
    for (final doc in txSnapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final type = (data['type'] as String?) ?? 'expense';
      final isIncome =
          type.toLowerCase().contains('revenu') || type == 'income';
      if (isIncome) {
        totalIncome += amount;
      } else {
        totalExpense += amount;
        final category =
            (data['categoryName'] as String?) ??
            (data['categoryId'] as String?) ??
            'Autre';
        expenseByCategory[category] =
            (expenseByCategory[category] ?? 0) + amount;
      }
    }

    return {
      'users': usersCount.count,
      'transactions': transactionsCount.count,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'expenseByCategory': expenseByCategory,
    };
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
