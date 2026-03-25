import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:budgetflow/l10n/app_localizations.dart';

import '../../models/transaction_model.dart';
import '../../routes/app_routes.dart';
import '../../services/firestore_service.dart';
import '../../services/api_service.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/language_controller.dart';

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
    final localization = AppLocalizations.of(context)!;
    try {
      if (user == null) {
        throw StateError(localization.userNotSignedIn);
      }
      await user.updateDisplayName(_nameController.text.trim());
      final newEmail = _emailController.text.trim();
      String message = localization.profileUpdated;
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        message = localization.verifyEmailSent;
      }
      await user.reload();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e.code));
    } catch (_) {
      _showError(localization.profileUpdateFailed);
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
    final localization = AppLocalizations.of(context)!;
    if (user == null) {
      _showError(localization.userNotSignedIn);
      return;
    }

    final hasPasswordProvider = user.providerData.any(
      (provider) => provider.providerId == 'password',
    );
    if (!hasPasswordProvider) {
      _showError(localization.externalProviderReset);
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
              title: Text(AppLocalizations.of(context)!.resetDataTitle),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.resetDataMessage),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
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
                          return AppLocalizations.of(context)!.enterPassword;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context)!.cancel),
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
                            final credential = EmailAuthProvider.credential(
                              email: email,
                              password: passwordController.text,
                            );
                            await user.reauthenticateWithCredential(credential);
                            await FirestoreService().resetUserData(user.uid);
                            if (!context.mounted) return;
                            Navigator.pop(context, true);
                          } on FirebaseAuthException catch (e) {
                            _showError(_mapAuthError(e.code));
                          } catch (_) {
                            _showError(
                              AppLocalizations.of(context)!.resetDataFailed,
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
                      : Text(AppLocalizations.of(context)!.reset),
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
      SnackBar(content: Text(AppLocalizations.of(context)!.resetDone)),
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAccountTitle),
          content: Text(AppLocalizations.of(context)!.deleteAccountMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: Text(AppLocalizations.of(context)!.delete),
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
      _showError(AppLocalizations.of(context)!.userNotSignedIn);
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
                            AppLocalizations.of(context)!.sendFeedback,
                            style: Theme.of(context).textTheme.titleMedium
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
                        initialValue: type,
                        items: [
                          DropdownMenuItem(
                            value: 'Bug',
                            child: Text(
                              AppLocalizations.of(context)!.feedbackBug,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Suggestion',
                            child: Text(
                              AppLocalizations.of(context)!.feedbackSuggestion,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Comment',
                            child: Text(
                              AppLocalizations.of(context)!.feedbackComment,
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => type = value);
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.feedbackType,
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
                          labelText: AppLocalizations.of(
                            context,
                          )!.feedbackMessage,
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
                            return AppLocalizations.of(
                              context,
                            )!.feedbackMessageRequired;
                          }
                          if (value.trim().length < 5) {
                            return AppLocalizations.of(
                              context,
                            )!.feedbackMessageShort;
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
                                      message: messageController.text.trim(),
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.feedbackThanks,
                                        ),
                                      ),
                                    );
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.feedbackFailed,
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
                              : Text(AppLocalizations.of(context)!.send),
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
      _showError(AppLocalizations.of(context)!.userNotSignedIn);
      return;
    }

    final hasPasswordProvider = user.providerData.any(
      (provider) => provider.providerId == 'password',
    );
    if (!hasPasswordProvider) {
      _showError(AppLocalizations.of(context)!.externalProviderChange);
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
                            AppLocalizations.of(context)!.changePassword,
                            style: Theme.of(context).textTheme.titleMedium
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
                          labelText: AppLocalizations.of(context)!.oldPassword,
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
                            return AppLocalizations.of(
                              context,
                            )!.enterOldPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: newController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.newPassword,
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
                            return AppLocalizations.of(
                              context,
                            )!.enterNewPassword;
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
                          labelText: AppLocalizations.of(
                            context,
                          )!.confirmPassword,
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
                            return AppLocalizations.of(
                              context,
                            )!.confirmPasswordRequired;
                          }
                          if (value != newController.text) {
                            return AppLocalizations.of(
                              context,
                            )!.passwordMismatch;
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
                                  final scaffoldContext = context;
                                  final localization = AppLocalizations.of(
                                    context,
                                  )!;
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
                                    await user.reauthenticateWithCredential(
                                      credential,
                                    );
                                    await user.updatePassword(
                                      newController.text,
                                    );
                                    if (!mounted) return;
                                    Navigator.pop(scaffoldContext);
                                    ScaffoldMessenger.of(
                                      scaffoldContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.passwordUpdated,
                                        ),
                                      ),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    _showError(_mapAuthError(e.code));
                                  } catch (_) {
                                    _showError(
                                      localization.passwordUpdateFailed,
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
                              : Text(AppLocalizations.of(context)!.update),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return AppLocalizations.of(context)!.oldPasswordIncorrect;
      case 'weak-password':
        return AppLocalizations.of(context)!.passwordTooShort;
      case 'requires-recent-login':
        return AppLocalizations.of(context)!.reauthenticateToContinue;
      case 'email-already-in-use':
        return AppLocalizations.of(context)!.emailAlreadyUsed;
      case 'invalid-email':
        return AppLocalizations.of(context)!.invalidEmail;
      default:
        return AppLocalizations.of(context)!.genericError;
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
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.profileTitle)),
        body: Center(
          child: Text(AppLocalizations.of(context)!.signInToSeeProfile),
        ),
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
                AppLocalizations.of(context)!.profileTitle,
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
                            user.displayName ??
                                AppLocalizations.of(context)!.defaultUserName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ??
                                AppLocalizations.of(context)!.defaultUserEmail,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: AppLocalizations.of(context)!.personalInfo),
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
                          labelText: AppLocalizations.of(context)!.fullName,
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
                            return AppLocalizations.of(context)!.enterName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.emailLabel,
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
                            return AppLocalizations.of(context)!.enterEmail;
                          }
                          if (!value.contains('@')) {
                            return AppLocalizations.of(context)!.invalidEmail;
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
                              : Text(AppLocalizations.of(context)!.update),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: AppLocalizations.of(context)!.preferences),
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
                  final currency = prefs['currency'] as String? ?? 'CDF';
                  final language = prefs['language'] as String? ?? 'fr';
                  final languageController = context.read<LanguageController>();
                  if (languageController.locale == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      languageController.setLocaleFromCode(language);
                    });
                  }
                  return _PreferencesCard(
                    notifications: notifications,
                    weeklyReport: weeklyReport,
                    currency: currency,
                    language:
                        languageController.locale?.languageCode ?? language,
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
                    onCurrencyChanged: (value) async {
                      final baseCurrency =
                          (prefs['baseCurrency'] as String?) ?? currency;
                      final rate = await ApiService().getRate(
                        from: baseCurrency,
                        to: value,
                      );
                      await FirestoreService().convertUserCurrency(
                        uid: user.uid,
                        baseCurrency: baseCurrency,
                        to: value,
                        rate: rate,
                      );
                    },
                    onLanguageChanged: (value) async {
                      await FirestoreService().updateUserPreferences(
                        user.uid,
                        language: value,
                      );
                      await languageController.setLocaleFromCode(value);
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
                  final currency = prefs['currency'] as String? ?? 'CDF';
                  final rate = (prefs['rate'] as num?)?.toDouble() ?? 1.0;
                  if (!weeklyReport) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: AppLocalizations.of(context)!.weeklySummaryTitle,
                      ),
                      const SizedBox(height: 12),
                      _WeeklyReportCard(
                        uid: user.uid,
                        currency: currency,
                        rate: rate,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
              _SectionTitle(title: AppLocalizations.of(context)!.security),
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
                      title: Text(AppLocalizations.of(context)!.changePassword),
                      onTap: _changePassword,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.restart_alt,
                        color: Color(0xFFFC7520),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.resetMyData,
                        style: TextStyle(color: Color(0xFFFC7520)),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.resetMyDataSubtitle,
                      ),
                      onTap: _resetUserData,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout),
                      title: Text(AppLocalizations.of(context)!.signOut),
                      onTap: _signOut,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Color(0xFFEF4444),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.deleteMyAccount,
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: AppLocalizations.of(context)!.comments),
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
                      title: Text(AppLocalizations.of(context)!.sendFeedback),
                      subtitle: Text(
                        AppLocalizations.of(context)!.sendFeedbackSubtitle,
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
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _PreferencesCard extends StatefulWidget {
  const _PreferencesCard({
    required this.notifications,
    required this.weeklyReport,
    required this.currency,
    required this.language,
    required this.onToggleNotifications,
    required this.onToggleWeeklyReport,
    required this.onCurrencyChanged,
    required this.onLanguageChanged,
  });

  final bool notifications;
  final bool weeklyReport;
  final String currency;
  final String language;
  final ValueChanged<bool> onToggleNotifications;
  final ValueChanged<bool> onToggleWeeklyReport;
  final Future<void> Function(String value) onCurrencyChanged;
  final Future<void> Function(String value) onLanguageChanged;

  @override
  State<_PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<_PreferencesCard> {
  bool _notifications = true;
  bool _weeklyReport = false;
  String _currency = 'CDF';
  String _pendingCurrency = 'CDF';
  String _language = 'fr';
  String _pendingLanguage = 'fr';
  bool _initialized = false;
  bool _savingCurrency = false;
  bool _savingLanguage = false;
  final _currencies = const ['CDF', 'USD', 'EUR', 'GBP', 'ZAR', 'NGN'];
  final _languages = const ['fr', 'en'];

  @override
  void didUpdateWidget(covariant _PreferencesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifications != widget.notifications) {
      _notifications = widget.notifications;
    }
    if (oldWidget.weeklyReport != widget.weeklyReport) {
      _weeklyReport = widget.weeklyReport;
    }
    if (oldWidget.currency != widget.currency) {
      _currency = widget.currency;
      _pendingCurrency = widget.currency;
    }
    if (oldWidget.language != widget.language) {
      _language = widget.language;
      _pendingLanguage = widget.language;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _notifications = widget.notifications;
      _weeklyReport = widget.weeklyReport;
      _currency = widget.currency;
      _pendingCurrency = widget.currency;
      _language = widget.language;
      _pendingLanguage = widget.language;
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
            title: Text(AppLocalizations.of(context)!.notifications),
            subtitle: Text(AppLocalizations.of(context)!.expenseAlerts),
            value: _notifications,
            onChanged: (value) {
              setState(() => _notifications = value);
              widget.onToggleNotifications(value);
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppLocalizations.of(context)!.weeklyReport),
            subtitle: Text(AppLocalizations.of(context)!.weeklySummary),
            value: _weeklyReport,
            onChanged: (value) {
              setState(() => _weeklyReport = value);
              widget.onToggleWeeklyReport(value);
            },
          ),
          const Divider(height: 1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.defaultCurrency,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _pendingCurrency,
                items: _currencies
                    .map(
                      (code) =>
                          DropdownMenuItem(value: code, child: Text(code)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _pendingCurrency = value);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.currency_exchange),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_pendingCurrency == _currency || _savingCurrency)
                      ? null
                      : () async {
                          final scaffoldContext = context;
                          final localization = AppLocalizations.of(context)!;
                          setState(() {
                            _savingCurrency = true;
                          });
                          if (!mounted) return;
                          showDialog(
                            context: scaffoldContext,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(localization.currencyUpdatingTitle),
                                content: Row(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        localization.currencyUpdatingBody,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                          try {
                            await widget.onCurrencyChanged(_pendingCurrency);
                            if (!mounted) return;
                            Navigator.pop(scaffoldContext);
                            setState(() {
                              _currency = _pendingCurrency;
                              _savingCurrency = false;
                            });
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(
                                content: Text(localization.currencyUpdated),
                              ),
                            );
                          } catch (_) {
                            if (!mounted) return;
                            Navigator.pop(scaffoldContext);
                            setState(() => _savingCurrency = false);
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localization.currencyUpdateFailed,
                                ),
                              ),
                            );
                          }
                        },
                  child: _savingCurrency
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.validateCurrency),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.defaultLanguage,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _pendingLanguage,
                items: _languages
                    .map(
                      (code) => DropdownMenuItem(
                        value: code,
                        child: Text(
                          code == 'en'
                              ? AppLocalizations.of(context)!.english
                              : AppLocalizations.of(context)!.french,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _pendingLanguage = value);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.language),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_pendingLanguage == _language || _savingLanguage)
                      ? null
                      : () async {
                          final scaffoldContext = context;
                          final localization = AppLocalizations.of(context)!;
                          setState(() => _savingLanguage = true);
                          try {
                            await widget.onLanguageChanged(_pendingLanguage);
                            if (!mounted) return;
                            setState(() {
                              _language = _pendingLanguage;
                              _savingLanguage = false;
                            });
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(
                                content: Text(localization.languageUpdated),
                              ),
                            );
                          } catch (_) {
                            if (!mounted) return;
                            setState(() => _savingLanguage = false);
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localization.languageUpdateFailed,
                                ),
                              ),
                            );
                          }
                        },
                  child: _savingLanguage
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.save),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text(AppLocalizations.of(context)!.darkMode),
                subtitle: Text(
                  themeController.isDark
                      ? AppLocalizations.of(context)!.darkModeDark
                      : AppLocalizations.of(context)!.darkModeLight,
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
  const _WeeklyReportCard({
    required this.uid,
    required this.currency,
    required this.rate,
  });

  final String uid;
  final String currency;
  final double rate;

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
            return Text(AppLocalizations.of(context)!.noWeeklyTransactions);
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
                AppLocalizations.of(context)!.weeklySummaryRange(
                  DateFormat('dd MMM').format(start),
                  DateFormat('dd MMM').format(end),
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              _WeeklyLine(
                label: AppLocalizations.of(context)!.income,
                value: _formatMoney(income, currency, rate),
                color: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 6),
              _WeeklyLine(
                label: AppLocalizations.of(context)!.expenses,
                value: _formatMoney(expense, currency, rate),
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 10),
              if (topCategory != null)
                Text(
                  AppLocalizations.of(context)!.topCategory(topCategory.key),
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
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

bool _isIncome(String type) {
  final value = type.toLowerCase();
  return value.contains('revenu') || value == 'income';
}

String _formatMoney(double value, String currency, double rate) {
  final formatter = NumberFormat.decimalPattern();
  return '${formatter.format((value * rate).round())} $currency';
}
