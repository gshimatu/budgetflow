import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF33CC33);
    const brandCyan = Color(0xFF0BC1DE);
    const brandOrange = Color(0xFFFC7520);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [brandCyan, Color(0xFFB9F3FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [brandGreen, Color(0xFFBFF5C8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderSection(
                    brandOrange: brandOrange,
                    brandGreen: brandGreen,
                  ),
                  const SizedBox(height: 20),
                  _BalanceCard(
                    brandGreen: brandGreen,
                    brandCyan: brandCyan,
                  ),
                  const SizedBox(height: 20),
                  _QuickActions(brandOrange: brandOrange),
                  const SizedBox(height: 20),
                  _BudgetOverview(brandGreen: brandGreen),
                  const SizedBox(height: 20),
                  _InsightsRow(
                    brandCyan: brandCyan,
                    brandOrange: brandOrange,
                  ),
                  const SizedBox(height: 20),
                  const _RecentTransactions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.brandOrange,
    required this.brandGreen,
  });

  final Color brandOrange;
  final Color brandGreen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo-budgetflow.png',
            width: 48,
            height: 48,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour,',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              Row(
                children: [
                  Text(
                    'BudgetFlow',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
          color: brandGreen,
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.brandGreen,
    required this.brandCyan,
  });

  final Color brandGreen;
  final Color brandCyan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [brandGreen, brandCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solde actuel',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '1 240 500 CDF',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BalanceChip(label: 'Revenus +18%', icon: Icons.trending_up),
              const SizedBox(width: 12),
              _BalanceChip(label: 'Dépenses -6%', icon: Icons.trending_down),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.brandOrange});

  final Color brandOrange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                label: 'Ajouter dépense',
                icon: Icons.remove_circle_outline,
                color: brandOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                label: 'Ajouter revenu',
                icon: Icons.add_circle_outline,
                color: const Color(0xFF22C55E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                label: 'Convertir',
                icon: Icons.currency_exchange,
                color: const Color(0xFF0BC1DE),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _BudgetOverview extends StatelessWidget {
  const _BudgetOverview({required this.brandGreen});

  final Color brandGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Objectif mensuel',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '75%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: brandGreen,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: 0.75,
              minHeight: 10,
              backgroundColor: const Color(0xFFE6EEF6),
              color: brandGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Budget restant : 410 000 CDF',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
          ),
        ],
      ),
    );
  }
}

class _InsightsRow extends StatelessWidget {
  const _InsightsRow({
    required this.brandCyan,
    required this.brandOrange,
  });

  final Color brandCyan;
  final Color brandOrange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InsightCard(
            title: 'Dépenses du mois',
            value: '380 000 CDF',
            color: brandOrange,
            icon: Icons.shopping_bag_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InsightCard(
            title: 'Revenus du mois',
            value: '620 000 CDF',
            color: brandCyan,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions récentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _TransactionTile(
          title: 'Supermarché',
          subtitle: 'Alimentation',
          amount: '- 42 000 CDF',
          icon: Icons.shopping_cart_outlined,
          color: const Color(0xFFFC7520),
        ),
        _TransactionTile(
          title: 'Salaire',
          subtitle: 'Revenu',
          amount: '+ 540 000 CDF',
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFF33CC33),
        ),
        _TransactionTile(
          title: 'Transport',
          subtitle: 'Taxi',
          amount: '- 8 500 CDF',
          icon: Icons.directions_car_outlined,
          color: const Color(0xFF0BC1DE),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amount.startsWith('-')
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF16A34A),
                ),
          ),
        ],
      ),
    );
  }
}
