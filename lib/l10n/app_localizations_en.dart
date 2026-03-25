// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BudgetFlow';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get defaultLanguage => 'App language';

  @override
  String get languageUpdated => 'Language updated.';

  @override
  String get languageUpdateFailed => 'Unable to update language.';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navCategories => 'Categories';

  @override
  String get navStats => 'Stats';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAdmin => 'Admin';

  @override
  String get hello => 'Hello,';

  @override
  String get balanceTitle => 'Current balance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get addExpense => 'Add expense';

  @override
  String get addIncome => 'Add income';

  @override
  String get convert => 'Convert';

  @override
  String get monthlyGoal => 'Monthly goal';

  @override
  String get toDefine => 'To set';

  @override
  String get edit => 'Edit';

  @override
  String get defineGoalHint => 'Set your goal for this month';

  @override
  String budgetRemaining(Object amount) {
    return 'Remaining budget: $amount';
  }

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get viewAll => 'View all';

  @override
  String get noTransactionsYet => 'No transactions yet.';

  @override
  String get converterTitle => 'Converter';

  @override
  String get amount => 'Amount';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get enterAmount => 'Please enter an amount';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get setMonthlyGoal => 'Set monthly goal';

  @override
  String amountWithCurrency(Object currency) {
    return 'Amount ($currency)';
  }

  @override
  String get goalUpdated => 'Goal updated.';

  @override
  String get updateFailed => 'Unable to update.';

  @override
  String get monthlyExpenses => 'Monthly expenses';

  @override
  String get monthlyIncome => 'Monthly income';

  @override
  String get signInToSeeData => 'Sign in to see your data.';

  @override
  String currencyFromTo(Object from, Object to) {
    return 'Currency: $from -> $to';
  }
}
