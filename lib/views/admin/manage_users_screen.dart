import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/firestore_service.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().watchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('Aucun utilisateur.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = users[index];
              final uid = user['id'] as String;
              final email = user['email'] as String? ?? '—';
              final role = user['role'] as String? ?? 'user';
              final createdAt = user['createdAt'];
              final createdDate = createdAt is Timestamp
                  ? createdAt.toDate()
                  : null;

              return ListTile(
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(email),
                subtitle: Text(
                  createdDate == null
                      ? 'Inscrit: —'
                      : 'Inscrit: ${DateFormat('dd MMM yyyy').format(createdDate)}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'toggle') {
                      final newRole = role == 'admin' ? 'user' : 'admin';
                      await FirestoreService().updateUserRole(uid, newRole);
                    } else if (value == 'delete') {
                      if (uid == currentUid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Impossible de supprimer votre compte.'),
                          ),
                        );
                        return;
                      }
                      final confirm = await _confirmDelete(context);
                      if (confirm) {
                        await FirestoreService().deleteUserProfile(uid);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                        role == 'admin'
                            ? 'Révoquer admin'
                            : 'Passer admin',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Supprimer'),
                    ),
                  ],
                ),
                leading: CircleAvatar(
                  child: Text(email.isNotEmpty ? email[0].toUpperCase() : '?'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer l’utilisateur'),
          content: const Text(
            'Cette action supprime uniquement le profil Firestore.',
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
    return confirm == true;
  }
}
