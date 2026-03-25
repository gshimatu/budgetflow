// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'BudgetFlow';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Francais';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get update => 'Mettre a jour';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get ok => 'OK';

  @override
  String get defaultLanguage => 'Langue de l\'application';

  @override
  String get languageUpdated => 'Langue mise a jour.';

  @override
  String get languageUpdateFailed => 'Mise a jour impossible.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navCategories => 'Categories';

  @override
  String get navStats => 'Stats';

  @override
  String get navProfile => 'Profil';

  @override
  String get navAdmin => 'Admin';

  @override
  String get hello => 'Bonjour,';

  @override
  String get balanceTitle => 'Solde actuel';

  @override
  String get income => 'Revenus';

  @override
  String get expenses => 'Depenses';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get addExpense => 'Ajouter depense';

  @override
  String get addIncome => 'Ajouter revenu';

  @override
  String get convert => 'Convertir';

  @override
  String get monthlyGoal => 'Objectif mensuel';

  @override
  String get toDefine => 'A definir';

  @override
  String get edit => 'Modifier';

  @override
  String get defineGoalHint => 'Definis ton objectif pour ce mois';

  @override
  String budgetRemaining(Object amount) {
    return 'Budget restant : $amount';
  }

  @override
  String get recentTransactions => 'Transactions recentes';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get noTransactionsYet => 'Aucune transaction pour le moment.';

  @override
  String get converterTitle => 'Convertisseur';

  @override
  String get amount => 'Montant';

  @override
  String get from => 'De';

  @override
  String get to => 'Vers';

  @override
  String get enterAmount => 'Veuillez saisir un montant';

  @override
  String get invalidAmount => 'Montant invalide';

  @override
  String get setMonthlyGoal => 'Definir l\'objectif mensuel';

  @override
  String amountWithCurrency(Object currency) {
    return 'Montant ($currency)';
  }

  @override
  String get goalUpdated => 'Objectif mis a jour.';

  @override
  String get updateFailed => 'Impossible de mettre a jour.';

  @override
  String get monthlyExpenses => 'Depenses du mois';

  @override
  String get monthlyIncome => 'Revenus du mois';

  @override
  String get signInToSeeData => 'Connectez-vous pour voir vos donnees.';

  @override
  String currencyFromTo(Object from, Object to) {
    return 'Devise: $from -> $to';
  }
}
