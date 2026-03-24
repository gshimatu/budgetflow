import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../services/api_service.dart';
import '../../services/firestore_service.dart';

Future<void> showTransactionForm(
  BuildContext context, {
  required String uid,
  String initialType = 'expense',
  TransactionModel? existing,
  String currency = 'CDF',
  String baseCurrency = 'CDF',
  double rate = 1.0,
}) async {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController(
      text: existing == null
          ? null
          : (existing.amount * rate).toStringAsFixed(2),
    );
  final noteController = TextEditingController(text: existing?.note ?? '');
  DateTime selectedDate = existing?.date ?? DateTime.now();
  String type = existing?.type ?? initialType;
  String? selectedCategory = existing?.categoryName;
  String? customCategory;
  String amountCurrency = currency;
  bool loadingRate = false;
  String? rateError;
  double? rateToBase;
  bool initialized = false;
  bool saving = false;

  final currencyOptions = <String>{
    'CDF',
    'USD',
    'EUR',
    'GBP',
    'ZAR',
    'NGN',
    currency,
    baseCurrency,
  }.toList()
    ..sort();

  double? _parseAmount() {
    final raw = amountController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  Future<void> _ensureRateToBase(
    String selected,
    void Function(VoidCallback fn) setState,
  ) async {
    if (selected == baseCurrency) {
      setState(() {
        rateToBase = 1.0;
        rateError = null;
      });
      return;
    }

    if (selected == currency) {
      final inverted = rate == 0 ? null : (1 / rate);
      setState(() {
        rateToBase = inverted;
        rateError = inverted == null ? 'Taux invalide' : null;
      });
      return;
    }

    setState(() {
      loadingRate = true;
      rateError = null;
    });
    try {
      final fetched = await ApiService().getRate(
        from: selected,
        to: baseCurrency,
      );
      setState(() {
        rateToBase = fetched;
        rateError = null;
      });
    } catch (e) {
      setState(() {
        rateError = e.toString().replaceFirst('Exception: ', '');
        rateToBase = null;
      });
    } finally {
      setState(() => loadingRate = false);
    }
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (!initialized) {
            initialized = true;
            Future.microtask(() {
              if (context.mounted) {
                _ensureRateToBase(amountCurrency, setState);
              }
            });
          }
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
              child: StreamBuilder<List<CategoryModel>>(
                stream: FirestoreService().watchGlobalCategories(),
                builder: (context, globalSnapshot) {
                  return StreamBuilder<List<CategoryModel>>(
                    stream: FirestoreService().watchUserCategories(uid),
                    builder: (context, userSnapshot) {
                      final globalCategories = globalSnapshot.data ?? [];
                      final userCategories = userSnapshot.data ?? [];
                      final names = <String>{};
                      for (final cat
                          in [...globalCategories, ...userCategories]) {
                        if (cat.name.trim().isNotEmpty) {
                          names.add(cat.name.trim());
                        }
                      }
                      final categoryItems = names.toList()..sort();
                      if (selectedCategory == null) {
                        selectedCategory = categoryItems.isNotEmpty
                            ? categoryItems.first
                            : 'Autre';
                      }
                      final isCustomCategory = selectedCategory != null &&
                          !categoryItems.contains(selectedCategory) &&
                          selectedCategory != 'Autre';
                      if (isCustomCategory && customCategory == null) {
                        customCategory = selectedCategory;
                        selectedCategory = 'Autre';
                      }

                      return Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  existing == null
                                      ? 'Nouvelle transaction'
                                      : 'Modifier la transaction',
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
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Montant',
                                prefixIcon:
                                    const Icon(Icons.payments_outlined),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 90,
                                ),
                                suffixIcon: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: amountCurrency,
                                    items: currencyOptions
                                        .map(
                                          (code) => DropdownMenuItem(
                                            value: code,
                                            child: Text(code),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: loadingRate
                                        ? null
                                        : (value) async {
                                            if (value == null) return;
                                            setState(() {
                                              amountCurrency = value;
                                              rateError = null;
                                              rateToBase = null;
                                            });
                                            await _ensureRateToBase(
                                              value,
                                              setState,
                                            );
                                          },
                                  ),
                                ),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez saisir un montant';
                                }
                                final parsed = double.tryParse(
                                  value.replaceAll(',', '.'),
                                );
                                if (parsed == null || parsed <= 0) {
                                  return 'Montant invalide';
                                }
                                return null;
                              },
                              onChanged: (_) {
                                if (rateError != null) return;
                                setState(() {});
                              },
                            ),
                            if (loadingRate || rateError != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (loadingRate)
                                    const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  if (loadingRate) const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      loadingRate
                                          ? 'Conversion en cours...'
                                          : (rateError ?? ''),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (amountCurrency != currency) ...[
                              const SizedBox(height: 8),
                              Builder(
                                builder: (context) {
                                  final parsed = _parseAmount();
                                  if (parsed == null || rateToBase == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final baseAmount = parsed * rateToBase!;
                                  final displayAmount = baseAmount * rate;
                                  final formatter =
                                      NumberFormat.decimalPattern();
                                  return Text(
                                    'Equivalent: ${formatter.format(displayAmount)} $currency',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: type,
                              items: const [
                                DropdownMenuItem(
                                  value: 'expense',
                                  child: Text('Dépense'),
                                ),
                                DropdownMenuItem(
                                  value: 'income',
                                  child: Text('Revenu'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => type = value);
                              },
                              decoration: InputDecoration(
                                labelText: 'Type',
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              items: [
                                ...categoryItems.map(
                                  (name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(name),
                                  ),
                                ),
                                const DropdownMenuItem(
                                  value: 'Autre',
                                  child: Text('Autre'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => selectedCategory = value);
                              },
                              decoration: InputDecoration(
                                labelText: 'Catégorie',
                                prefixIcon:
                                    const Icon(Icons.category_outlined),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez choisir une catégorie';
                                }
                                return null;
                              },
                            ),
                            if (selectedCategory == 'Autre') ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Nom de la catégorie',
                                  prefixIcon:
                                      const Icon(Icons.edit_outlined),
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) => customCategory = value,
                                validator: (value) {
                                  if (selectedCategory == 'Autre' &&
                                      (value == null ||
                                          value.trim().isEmpty)) {
                                    return 'Veuillez saisir une catégorie';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: noteController,
                              decoration: InputDecoration(
                                labelText: 'Note (optionnel)',
                                prefixIcon: const Icon(Icons.note_outlined),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                      initialDate: selectedDate,
                                    );
                                    if (picked != null) {
                                      setState(() => selectedDate = picked);
                                    }
                                  },
                                  child: const Text('Choisir'),
                                ),
                              ],
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
                                          final amount = double.parse(
                                            amountController.text
                                                .trim()
                                                .replaceAll(',', '.'),
                                          );
                                          double baseAmount;
                                          if (amountCurrency == baseCurrency) {
                                            baseAmount = amount;
                                          } else if (amountCurrency == currency) {
                                            baseAmount = rate == 0
                                                ? amount
                                                : amount / rate;
                                          } else {
                                            double? localRate = rateToBase;
                                            if (localRate == null) {
                                              try {
                                                localRate = await ApiService()
                                                    .getRate(
                                                  from: amountCurrency,
                                                  to: baseCurrency,
                                                );
                                                setState(() => rateToBase = localRate);
                                              } catch (e) {
                                                setState(() {
                                                  saving = false;
                                                  rateError = e
                                                      .toString()
                                                      .replaceFirst('Exception: ', '');
                                                });
                                                return;
                                              }
                                            }
                                            baseAmount = amount * localRate;
                                          }
                                          final chosen =
                                              selectedCategory == 'Autre'
                                                  ? (customCategory ?? '')
                                                  : (selectedCategory ?? '');
                                          final categoryName = chosen.trim();
                                          final transaction = TransactionModel(
                                            id: existing?.id ?? '',
                                            amount: baseAmount,
                                            type: type,
                                            categoryId:
                                                categoryName.toLowerCase().trim(),
                                            categoryName: categoryName,
                                            date: selectedDate,
                                            note: noteController.text.trim(),
                                          );
                                          if (existing == null) {
                                            await FirestoreService()
                                                .addTransaction(uid, transaction);
                                          } else {
                                            await FirestoreService()
                                                .updateTransaction(
                                              uid,
                                              existing.id,
                                              transaction,
                                            );
                                          }
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }
                                        } catch (_) {
                                          if (context.mounted) {
                                            setState(() => saving = false);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Impossible d'enregistrer la transaction.",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                child: Text(
                                  existing == null ? 'Ajouter' : 'Mettre à jour',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
}
