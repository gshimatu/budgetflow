import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class UserController extends ChangeNotifier {
  UserController() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<Map<String, dynamic>>? _profileSub;

  bool _isAdmin = false;
  String? _displayName;
  String? _email;
  String? _photoUrl;
  String? _uid;
  bool _loaded = false;

  bool get isAdmin => _isAdmin;
  String? get displayName => _displayName;
  String? get email => _email;
  String? get photoUrl => _photoUrl;
  String? get uid => _uid;
  bool get isLoaded => _loaded;

  void _onAuthChanged(User? user) {
    _profileSub?.cancel();
    if (user == null) {
      _uid = null;
      _displayName = null;
      _email = null;
      _photoUrl = null;
      _isAdmin = false;
      _loaded = true;
      notifyListeners();
      return;
    }

    _uid = user.uid;
    _displayName = user.displayName;
    _email = user.email;
    _photoUrl = user.photoURL;

    _profileSub =
        FirestoreService().watchUserProfile(user.uid).listen((data) {
      final role = (data['role'] as String?) ?? 'user';
      _isAdmin = role == 'admin';
      _displayName = (data['displayName'] as String?) ?? _displayName;
      _email = (data['email'] as String?) ?? _email;
      _loaded = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
