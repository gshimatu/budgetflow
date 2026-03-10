import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    setLoading(true);
    setError(null);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setAuthenticated(true);
      return true;
    } on FirebaseAuthException catch (e) {
      setError(_mapAuthError(e.code));
      return false;
    } catch (_) {
      setError('Une erreur est survenue. Réessaie plus tard.');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    setLoading(true);
    setError(null);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }
      setAuthenticated(true);
      return true;
    } on FirebaseAuthException catch (e) {
      setError(_mapAuthError(e.code));
      return false;
    } catch (_) {
      setError('Une erreur est survenue. Réessaie plus tard.');
      return false;
    } finally {
      setLoading(false);
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Mot de passe trop faible.';
      case 'user-disabled':
        return 'Ce compte est désactivé.';
      case 'user-not-found':
        return 'Aucun compte trouvé pour cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessaie plus tard.';
      default:
        return 'Connexion impossible. Vérifie vos informations.';
    }
  }
}
