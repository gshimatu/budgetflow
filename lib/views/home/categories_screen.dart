import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgetflow/l10n/app_localizations.dart';

import '../../models/category_model.dart';
import '../../services/firestore_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    FirestoreService().ensureDefaultGlobalCategories();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navCategories)),
        body: Center(child: Text(l10n.signInToManageCategories)),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(l10n.navCategories),
        actions: [
          IconButton(
            onPressed: () => _openAddCategory(context, user.uid),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _SectionTitle(title: l10n.globalCategoriesTitle),
          const SizedBox(height: 12),
          StreamBuilder<List<CategoryModel>>(
            stream: FirestoreService().watchGlobalCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return Text(l10n.noGlobalCategories);
              }
              return _CategoryGrid(categories: categories);
            },
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: l10n.myCategoriesTitle),
          const SizedBox(height: 12),
          StreamBuilder<List<CategoryModel>>(
            stream: FirestoreService().watchUserCategories(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return Text(l10n.noUserCategories);
              }
              return _CategoryGrid(categories: categories);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddCategory(context, user.uid),
        label: Text(l10n.add),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openAddCategory(BuildContext context, String uid) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    String type = 'expense';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                final l10n = AppLocalizations.of(context)!;
                return Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.newCategory,
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
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.categoryName,
                          prefixIcon: const Icon(Icons.category_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF2F6FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterCategoryName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: type,
                        items: [
                          DropdownMenuItem(
                            value: 'expense',
                            child: Text(l10n.expense),
                          ),
                          DropdownMenuItem(
                            value: 'income',
                            child: Text(l10n.income),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => type = value);
                        },
                        decoration: InputDecoration(
                          labelText: l10n.type,
                          filled: true,
                          fillColor: const Color(0xFFF2F6FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }
                            final name = nameController.text.trim();
                            final category = CategoryModel(
                              id: '',
                              name: name,
                              type: type,
                              userId: uid,
                              order: DateTime.now().millisecondsSinceEpoch,
                            );
                            await FirestoreService().addUserCategory(
                              uid,
                              category,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(l10n.add),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories
          .map(
            (cat) => Chip(
              label: Text(cat.name),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
          )
          .toList(),
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
