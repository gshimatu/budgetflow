import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  bool _isAdmin = false;
  String? _displayName;
  String? _email;
  String? _photoUrl;

  bool get isAdmin => _isAdmin;
  String? get displayName => _displayName;
  String? get email => _email;
  String? get photoUrl => _photoUrl;

  void setProfile({
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isAdmin,
  }) {
    _displayName = displayName ?? _displayName;
    _email = email ?? _email;
    _photoUrl = photoUrl ?? _photoUrl;
    _isAdmin = isAdmin ?? _isAdmin;
    notifyListeners();
  }
}
