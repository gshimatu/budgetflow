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

  @override
  String get transactions => 'Transactions';

  @override
  String get signInToSeeTransactions => 'Sign in to view your transactions.';

  @override
  String get noTransactionsRecorded => 'No transactions recorded.';

  @override
  String get filterTransactions => 'Filter transactions';

  @override
  String get filterAll => 'All';

  @override
  String get filterToday => 'Today';

  @override
  String get filterPickDay => 'Pick a day';

  @override
  String get filterWeek => 'This week';

  @override
  String get filterMonth => 'This month';

  @override
  String get filterYear => 'This year';

  @override
  String get emptyToday => 'No transactions today.';

  @override
  String get emptyDay => 'No transactions for this day.';

  @override
  String get emptyWeek => 'No transactions this week.';

  @override
  String get emptyMonth => 'No transactions this month.';

  @override
  String get emptyYear => 'No transactions this year.';

  @override
  String get emptyAll => 'No transactions recorded.';

  @override
  String get deleteTransactionTitle => 'Delete transaction';

  @override
  String get deleteTransactionMessage =>
      'Do you really want to delete this transaction?';

  @override
  String filterDayLabel(Object date) {
    return 'Day: $date';
  }

  @override
  String get confirmDelete => 'Delete';

  @override
  String get today => 'Today';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get type => 'Type';

  @override
  String get expense => 'Expense';

  @override
  String get category => 'Category';

  @override
  String get other => 'Other';

  @override
  String get categoryName => 'Category name';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get date => 'Date';

  @override
  String get choose => 'Choose';

  @override
  String amountEquivalent(Object amount) {
    return 'Equivalent: $amount';
  }

  @override
  String get converting => 'Conversion in progress...';

  @override
  String get invalidRate => 'Invalid rate';

  @override
  String get saveFailed => 'Unable to save.';

  @override
  String get transactionSaveFailed => 'Unable to save the transaction.';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get signInToSeeStats => 'Sign in to see your statistics.';

  @override
  String get statsNoTransactions => 'No transactions yet.';

  @override
  String get expensesBreakdown => 'Expenses breakdown';

  @override
  String get monthlyEvolution => 'Monthly evolution';

  @override
  String get dailyExpenseTrendTitle => 'Trend (polygon) - Daily expenses';

  @override
  String get monthLabel => 'Month';

  @override
  String get yearLabel => 'Year';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get monthlyEvolutionNote => 'Evolution over the last 6 months shown.';

  @override
  String get dailyEvolutionNote =>
      'Daily expense evolution for the selected month.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get fullName => 'Full name';

  @override
  String get emailLabel => 'Email';

  @override
  String get updateProfile => 'Update';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get verifyEmailSent =>
      'A verification email has been sent. Confirm it to change your email.';

  @override
  String get profileUpdateFailed => 'Unable to update profile.';

  @override
  String get userNotSignedIn => 'User not signed in.';

  @override
  String get resetDataTitle => 'Reset data';

  @override
  String get resetDataMessage =>
      'This action deletes all your transactions and custom categories.\nConfirm with your password.';

  @override
  String get password => 'Password';

  @override
  String get reset => 'Reset';

  @override
  String get resetDone => 'Data reset.';

  @override
  String get resetDataFailed => 'Unable to reset data.';

  @override
  String get defaultUserName => 'User';

  @override
  String get defaultUserEmail => 'No email';

  @override
  String get selectCategory => 'Please select a category';

  @override
  String get enterCategoryName => 'Please enter a category name';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountMessage =>
      'This action is irreversible. Do you want to continue?';

  @override
  String get deleteFailed => 'Deletion failed. Try again later.';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get feedbackType => 'Type';

  @override
  String get feedbackBug => 'Report a bug';

  @override
  String get feedbackSuggestion => 'Improvement suggestion';

  @override
  String get feedbackComment => 'General comment';

  @override
  String get feedbackMessage => 'Your message';

  @override
  String get feedbackMessageRequired => 'Please enter a message';

  @override
  String get feedbackMessageShort => 'Message too short';

  @override
  String get feedbackThanks => 'Thanks for your feedback.';

  @override
  String get feedbackFailed => 'Unable to send. Try again later.';

  @override
  String get changePassword => 'Change password';

  @override
  String get oldPassword => 'Old password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordTooShort => 'Password too short';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordUpdated => 'Password updated.';

  @override
  String get passwordUpdateFailed => 'Unable to update password.';

  @override
  String get externalProviderReset =>
      'Signed in via external provider. Use that provider to reset your account.';

  @override
  String get externalProviderChange =>
      'Signed in via external provider. Change password from that provider.';

  @override
  String get signOut => 'Sign out';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get expenseAlerts => 'Spending alerts';

  @override
  String get weeklyReport => 'Weekly report';

  @override
  String get weeklySummary => 'Summary every Monday';

  @override
  String get defaultCurrency => 'Default currency';

  @override
  String get validateCurrency => 'Validate currency';

  @override
  String get currencyUpdatingTitle => 'Conversion in progress';

  @override
  String get currencyUpdatingBody => 'Updating currency...';

  @override
  String get currencyUpdated => 'Currency updated.';

  @override
  String get currencyUpdateFailed => 'Unable to update.';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeLight => 'Light';

  @override
  String get darkModeDark => 'Dark';

  @override
  String get weeklySummaryTitle => 'Weekly summary';

  @override
  String get noWeeklyTransactions => 'No transactions this week.';

  @override
  String topCategory(Object category) {
    return 'Top category: $category';
  }

  @override
  String get security => 'Security';

  @override
  String get resetMyData => 'Reset my data';

  @override
  String get resetMyDataSubtitle => 'Deletes all transactions and categories.';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get comments => 'Comments';

  @override
  String get sendFeedbackSubtitle => 'Report a bug or suggest an improvement.';

  @override
  String get signInToSeeProfile => 'Sign in to view your profile.';

  @override
  String get send => 'Send';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get enterOldPassword => 'Please enter your old password';

  @override
  String get enterNewPassword => 'Please enter a new password';

  @override
  String get confirmPasswordRequired => 'Please confirm the password';

  @override
  String get reauthenticateToContinue => 'Please reauthenticate to continue.';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get noExpenseThisMonth => 'No expenses for this month.';

  @override
  String get noDataForPeriod => 'No data for this period.';

  @override
  String weeklySummaryRange(Object end, Object start) {
    return 'From $start to $end';
  }

  @override
  String get oldPasswordIncorrect => 'Old password is incorrect.';

  @override
  String get emailAlreadyUsed => 'Email already in use.';

  @override
  String get invalidEmail => 'Invalid email address.';

  @override
  String get genericError => 'An error occurred.';
}
