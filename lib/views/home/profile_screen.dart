import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart';
import '../../routes/app_routes.dart';
import '../../services/firestore_service.dart';
import '../../controllers/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    try {
      if (user == null) {
        throw StateError('Utilisateur non connecté.');
      }
      await user.updateDisplayName(_nameController.text.trim());
      final newEmail = _emailController.text.trim();
      String message = 'Profil mis à jour.';
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        message =
            'Un email de vérification a été envoyé. Validez-le pour changer votre email.';
      }
      await user.reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e.code));
    } catch (_) {
      _showError('Impossible de mettre à jour le profil.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }


  Future<void> _resetUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Utilisateur non connecte.');
      return;
    }

    final hasPasswordProvider = user.providerData
        .any((provider) => provider.providerId == 'password');
    if (!hasPasswordProvider) {
      _showError(
        'Connexion via un fournisseur externe. Utilisez ce fournisseur pour reinitialiser votre compte.',
      );
      return;
    }

    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;
    bool saving = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reinitialiser les donnees'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Cette action supprime toutes vos transactions et categories personnalisees.\nConfirmez avec votre mot de passe.',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir votre mot de passe';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          setState(() => saving = true);
                          try {
                            final email = user.email;
                            if (email == null) {
                              throw FirebaseAuthException(
                                code: 'invalid-email',
                              );
                            }
                            final credential =
                                EmailAuthProvider.credential(
                              email: email,
                              password: passwordController.text,
                            );
                            await user
                                .reauthenticateWithCredential(credential);
                            await FirestoreService().resetUserData(user.uid);
                            if (!context.mounted) return;
                            Navigator.pop(context, true);
                          } on FirebaseAuthException catch (e) {
                            _showError(_mapAuthError(e.code));
                          } catch (_) {
                            _showError('Reinitialisation impossible.');
                          } finally {
                            if (context.mounted) {
                              setState(() => saving = false);
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Reinitialiser'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Donnees reinitialisees.')),
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text(
            'Cette action est irréversible. Voulez-vous continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.delete();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e.code));
    } catch (_) {
      _showError('Suppression impossible. Réessaie plus tard.');
    }
  }

  Future<void> _sendFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Utilisateur non connecte.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final messageController = TextEditingController();
    String type = 'Suggestion';
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Envoyer un commentaire',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: type,
                        items: const [
                          DropdownMenuItem(
                            value: 'Bug',
                            child: Text('Signaler un bug'),
                          ),
                          DropdownMenuItem(
                            value: 'Suggestion',
                            child: Text('Suggestion d\'amelioration'),
                          ),
                          DropdownMenuItem(
                            value: 'Commentaire',
                            child: Text('Commentaire general'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => type = value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Type',
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: messageController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Votre message',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir un message';
                          }
                          if (value.trim().length < 5) {
                            return 'Message trop court';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  setState(() => saving = true);
                                  try {
                                    await FirestoreService().addFeedback(
                                      uid: user.uid,
                                      email: user.email,
                                      type: type,
                                      message:
                                          messageController.text.trim(),
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Merci pour votre retour.'),
                                      ),
                                    );
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Envoi impossible. Reessaie plus tard.',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => saving = false);
                                    }
                                  }
                                },
                          child: saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Envoyer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Utilisateur non connecte.');
      return;
    }

    final hasPasswordProvider = user.providerData
        .any((provider) => provider.providerId == 'password');
    if (!hasPasswordProvider) {
      _showError(
        'Connexion via un fournisseur externe. Changez le mot de passe depuis ce fournisseur.',
      );
      return;
    }

    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Changer le mot de passe',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: oldController,
                        obscureText: obscureOld,
                        decoration: InputDecoration(
                          labelText: 'Ancien mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => obscureOld = !obscureOld),
                            icon: Icon(
                              obscureOld
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir l\'ancien mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: newController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'Nouveau mot de passe',
                          prefixIcon: const Icon(Icons.lock_reset),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => obscureNew = !obscureNew),
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir un nouveau mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Au moins 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => obscureConfirm = !obscureConfirm,
                            ),
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer le mot de passe';
                          }
                          if (value != newController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  setState(() => saving = true);
                                  try {
                                    final email = user.email;
                                    if (email == null) {
                                      throw FirebaseAuthException(
                                        code: 'invalid-email',
                                      );
                                    }
                                    final credential =
                                        EmailAuthProvider.credential(
                                      email: email,
                                      password: oldController.text,
                                    );
                                    await user
                                        .reauthenticateWithCredential(
                                            credential);
                                    await user
                                        .updatePassword(newController.text);
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Mot de passe mis a jour.'),
                                      ),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    _showError(_mapAuthError(e.code));
                                  } catch (_) {
                                    _showError(
                                      'Impossible de changer le mot de passe.',
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => saving = false);
                                    }
                                  }
                                },
                          child: saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Mettre a jour'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Ancien mot de passe incorrect.';
      case 'weak-password':
        return 'Mot de passe trop faible.';
      case 'requires-recent-login':
        return 'Veuillez vous reconnecter pour continuer.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      default:
        return 'Une erreur est survenue.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const brandGreen = Color(0xFF33CC33);
    const brandCyan = Color(0xFF0BC1DE);
    final scheme = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Connectez-vous pour voir votre profil.')),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [brandGreen, brandCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      backgroundImage: user.photoURL == null
                          ? const AssetImage(
                              'assets/images/logo-budgetflow.png',
                            )
                          : NetworkImage(user.photoURL!) as ImageProvider,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? 'Utilisateur BudgetFlow',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? 'email@exemple.com',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Informations personnelles'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom complet',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir votre nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.mail_outline),
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: brandGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Mettre à jour'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Préférences'),
              const SizedBox(height: 12),
              StreamBuilder<Map<String, dynamic>>(
                stream: FirestoreService().watchUserProfile(user.uid),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? {};
                  final prefs =
                      (data['preferences'] as Map?)?.cast<String, dynamic>() ??
                          {};
                  final notifications = prefs['notifications'] as bool? ?? true;
                  final weeklyReport = prefs['weeklyReport'] as bool? ?? false;
                  return _PreferencesCard(
                    notifications: notifications,
                    weeklyReport: weeklyReport,
                    onToggleNotifications: (value) {
                      FirestoreService().updateUserPreferences(
                        user.uid,
                        notifications: value,
                      );
                    },
                    onToggleWeeklyReport: (value) {
                      FirestoreService().updateUserPreferences(
                        user.uid,
                        weeklyReport: value,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder<Map<String, dynamic>>(
                stream: FirestoreService().watchUserProfile(user.uid),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? {};
                  final prefs =
                      (data['preferences'] as Map?)?.cast<String, dynamic>() ??
                          {};
                  final weeklyReport = prefs['weeklyReport'] as bool? ?? false;
                  if (!weeklyReport) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: 'Résumé hebdomadaire'),
                      const SizedBox(height: 12),
                      _WeeklyReportCard(uid: user.uid),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
              _SectionTitle(title: 'Sécurité'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lock_reset),
                      title: const Text('Changer le mot de passe'),
                      onTap: _changePassword,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.restart_alt,
                          color: Color(0xFFFC7520)),
                      title: const Text(
                        'Reinitialiser mes donnees',
                        style: TextStyle(color: Color(0xFFFC7520)),
                      ),
                      subtitle: const Text(
                        'Supprime toutes les transactions et categories.',
                      ),
                      onTap: _resetUserData,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout),
                      title: const Text('Se déconnecter'),
                      onTap: _signOut,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_forever,
                          color: Color(0xFFEF4444)),
                      title: const Text(
                        'Supprimer mon compte',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Commentaires'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: const Text('Envoyer un commentaire'),
                      subtitle: const Text(
                        'Signaler un bug ou proposer une amelioration.',
                      ),
                      onTap: _sendFeedback,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _PreferencesCard extends StatefulWidget {
  const _PreferencesCard({
    required this.notifications,
    required this.weeklyReport,
    required this.onToggleNotifications,
    required this.onToggleWeeklyReport,
  });

  final bool notifications;
  final bool weeklyReport;
  final ValueChanged<bool> onToggleNotifications;
  final ValueChanged<bool> onToggleWeeklyReport;

  @override
  State<_PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<_PreferencesCard> {
  bool _notifications = true;
  bool _weeklyReport = false;
  bool _initialized = false;

  @override
  void didUpdateWidget(covariant _PreferencesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifications != widget.notifications) {
      _notifications = widget.notifications;
    }
    if (oldWidget.weeklyReport != widget.weeklyReport) {
      _weeklyReport = widget.weeklyReport;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _notifications = widget.notifications;
      _weeklyReport = widget.weeklyReport;
      _initialized = true;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notifications'),
            subtitle: const Text('Alertes sur vos dépenses'),
            value: _notifications,
            onChanged: (value) {
              setState(() => _notifications = value);
              widget.onToggleNotifications(value);
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Rapport hebdo'),
            subtitle: const Text('Résumé chaque lundi'),
            value: _weeklyReport,
            onChanged: (value) {
              setState(() => _weeklyReport = value);
              widget.onToggleWeeklyReport(value);
            },
          ),
          const Divider(height: 1),
          Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Mode sombre'),
                subtitle: Text(
                  themeController.isDark ? 'Sombre' : 'Clair',
                ),
                value: themeController.isDark,
                onChanged: (value) {
                  themeController.setDarkMode(value);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeeklyReportCard extends StatelessWidget {
  const _WeeklyReportCard({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: StreamBuilder<List<TransactionModel>>(
        stream: FirestoreService().watchTransactions(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          final end = DateTime.now();
          final start = end.subtract(const Duration(days: 7));
          final weekly = items
              .where((tx) => tx.date.isAfter(start) && tx.date.isBefore(end))
              .toList();
          if (weekly.isEmpty) {
            return const Text('Aucune transaction cette semaine.');
          }
          double income = 0;
          double expense = 0;
          final Map<String, double> categories = {};
          for (final tx in weekly) {
            if (_isIncome(tx.type)) {
              income += tx.amount;
            } else {
              expense += tx.amount;
              final label = tx.categoryName?.isNotEmpty == true
                  ? tx.categoryName!
                  : tx.categoryId;
              categories[label] = (categories[label] ?? 0) + tx.amount;
            }
          }
          final topCategory = categories.entries.isEmpty
              ? null
              : (categories.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value)))
                  .first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Semaine du ${DateFormat('dd MMM').format(start)} au ${DateFormat('dd MMM').format(end)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 12),
              _WeeklyLine(
                label: 'Revenus',
                value: _formatMoney(income),
                color: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 6),
              _WeeklyLine(
                label: 'Dépenses',
                value: _formatMoney(expense),
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 10),
              if (topCategory != null)
                Text(
                  'Catégorie principale : ${topCategory.key}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WeeklyLine extends StatelessWidget {
  const _WeeklyLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

bool _isIncome(String type) {
  final value = type.toLowerCase();
  return value.contains('revenu') || value == 'income';
}

String _formatMoney(double value) {
  final formatter = NumberFormat.decimalPattern();
  return '${formatter.format(value.round())} CDF';
}

