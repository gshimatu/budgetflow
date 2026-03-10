import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/firestore_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _searchController = TextEditingController();
  String _roleFilter = 'all';
  bool _sortAsc = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: Column(
        children: [
          _SearchFilters(
            controller: _searchController,
            roleFilter: _roleFilter,
            sortAsc: _sortAsc,
            onRoleChanged: (value) => setState(() => _roleFilter = value),
            onSortChanged: (value) => setState(() => _sortAsc = value),
            onQueryChanged: (_) => setState(() {}),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().watchUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = _applyFilters(snapshot.data ?? []);
                if (users.isEmpty) {
                  return const Center(child: Text('Aucun utilisateur.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final uid = user['id'] as String;
                    final email = user['email'] as String? ?? '—';
                    final role = user['role'] as String? ?? 'user';
                    final createdAt = user['createdAt'];
                    final createdDate =
                        createdAt is Timestamp ? createdAt.toDate() : null;

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
                      leading: CircleAvatar(
                        child: Text(
                          email.isNotEmpty ? email[0].toUpperCase() : '?',
                        ),
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
                                  content: Text(
                                    'Impossible de supprimer votre compte.',
                                  ),
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> users) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = users.where((user) {
      final email = (user['email'] as String? ?? '').toLowerCase();
      final role = (user['role'] as String? ?? 'user');
      final matchesQuery = query.isEmpty || email.contains(query);
      final matchesRole =
          _roleFilter == 'all' || _roleFilter == role;
      return matchesQuery && matchesRole;
    }).toList();

    filtered.sort((a, b) {
      final aDate = a['createdAt'] is Timestamp
          ? (a['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b['createdAt'] is Timestamp
          ? (b['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);
      final result = aDate.compareTo(bDate);
      return _sortAsc ? result : -result;
    });

    return filtered;
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

class _SearchFilters extends StatelessWidget {
  const _SearchFilters({
    required this.controller,
    required this.roleFilter,
    required this.sortAsc,
    required this.onRoleChanged,
    required this.onSortChanged,
    required this.onQueryChanged,
  });

  final TextEditingController controller;
  final String roleFilter;
  final bool sortAsc;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<bool> onSortChanged;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher par email',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: roleFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous')),
                    DropdownMenuItem(value: 'admin', child: Text('Admins')),
                    DropdownMenuItem(value: 'user', child: Text('Utilisateurs')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    onRoleChanged(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Filtre',
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<bool>(
                  value: sortAsc,
                  items: const [
                    DropdownMenuItem(value: false, child: Text('Récent')),
                    DropdownMenuItem(value: true, child: Text('Ancien')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    onSortChanged(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Ordre',
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
