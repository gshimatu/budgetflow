import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'BudgetFlow'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @defaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get defaultLanguage;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated.'**
  String get languageUpdated;

  /// No description provided for @languageUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update language.'**
  String get languageUpdateFailed;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get navAdmin;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get hello;

  /// No description provided for @balanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get balanceTitle;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get addIncome;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @monthlyGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly goal'**
  String get monthlyGoal;

  /// No description provided for @toDefine.
  ///
  /// In en, this message translates to:
  /// **'To set'**
  String get toDefine;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @defineGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Set your goal for this month'**
  String get defineGoalHint;

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining budget: {amount}'**
  String budgetRemaining(Object amount);

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get noTransactionsYet;

  /// No description provided for @converterTitle.
  ///
  /// In en, this message translates to:
  /// **'Converter'**
  String get converterTitle;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get enterAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @setMonthlyGoal.
  ///
  /// In en, this message translates to:
  /// **'Set monthly goal'**
  String get setMonthlyGoal;

  /// No description provided for @amountWithCurrency.
  ///
  /// In en, this message translates to:
  /// **'Amount ({currency})'**
  String amountWithCurrency(Object currency);

  /// No description provided for @goalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goal updated.'**
  String get goalUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update.'**
  String get updateFailed;

  /// No description provided for @monthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly expenses'**
  String get monthlyExpenses;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get monthlyIncome;

  /// No description provided for @signInToSeeData.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your data.'**
  String get signInToSeeData;

  /// No description provided for @currencyFromTo.
  ///
  /// In en, this message translates to:
  /// **'Currency: {from} -> {to}'**
  String currencyFromTo(Object from, Object to);

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @signInToSeeTransactions.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your transactions.'**
  String get signInToSeeTransactions;

  /// No description provided for @noTransactionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No transactions recorded.'**
  String get noTransactionsRecorded;

  /// No description provided for @filterTransactions.
  ///
  /// In en, this message translates to:
  /// **'Filter transactions'**
  String get filterTransactions;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterPickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get filterPickDay;

  /// No description provided for @filterWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get filterWeek;

  /// No description provided for @filterMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get filterMonth;

  /// No description provided for @filterYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get filterYear;

  /// No description provided for @emptyToday.
  ///
  /// In en, this message translates to:
  /// **'No transactions today.'**
  String get emptyToday;

  /// No description provided for @emptyDay.
  ///
  /// In en, this message translates to:
  /// **'No transactions for this day.'**
  String get emptyDay;

  /// No description provided for @emptyWeek.
  ///
  /// In en, this message translates to:
  /// **'No transactions this week.'**
  String get emptyWeek;

  /// No description provided for @emptyMonth.
  ///
  /// In en, this message translates to:
  /// **'No transactions this month.'**
  String get emptyMonth;

  /// No description provided for @emptyYear.
  ///
  /// In en, this message translates to:
  /// **'No transactions this year.'**
  String get emptyYear;

  /// No description provided for @emptyAll.
  ///
  /// In en, this message translates to:
  /// **'No transactions recorded.'**
  String get emptyAll;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this transaction?'**
  String get deleteTransactionMessage;

  /// No description provided for @filterDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day: {date}'**
  String filterDayLabel(Object date);

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDelete;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @newTransaction.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get newTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @amountEquivalent.
  ///
  /// In en, this message translates to:
  /// **'Equivalent: {amount}'**
  String amountEquivalent(Object amount);

  /// No description provided for @converting.
  ///
  /// In en, this message translates to:
  /// **'Conversion in progress...'**
  String get converting;

  /// No description provided for @invalidRate.
  ///
  /// In en, this message translates to:
  /// **'Invalid rate'**
  String get invalidRate;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save.'**
  String get saveFailed;

  /// No description provided for @transactionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the transaction.'**
  String get transactionSaveFailed;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @signInToSeeStats.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your statistics.'**
  String get signInToSeeStats;

  /// No description provided for @statsNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get statsNoTransactions;

  /// No description provided for @expensesBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expenses breakdown'**
  String get expensesBreakdown;

  /// No description provided for @monthlyEvolution.
  ///
  /// In en, this message translates to:
  /// **'Monthly evolution'**
  String get monthlyEvolution;

  /// No description provided for @dailyExpenseTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Trend (polygon) - Daily expenses'**
  String get dailyExpenseTrendTitle;

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthLabel;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @monthlyEvolutionNote.
  ///
  /// In en, this message translates to:
  /// **'Evolution over the last 6 months shown.'**
  String get monthlyEvolutionNote;

  /// No description provided for @dailyEvolutionNote.
  ///
  /// In en, this message translates to:
  /// **'Daily expense evolution for the selected month.'**
  String get dailyEvolutionNote;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @verifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent. Confirm it to change your email.'**
  String get verifyEmailSent;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update profile.'**
  String get profileUpdateFailed;

  /// No description provided for @userNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'User not signed in.'**
  String get userNotSignedIn;

  /// No description provided for @resetDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset data'**
  String get resetDataTitle;

  /// No description provided for @resetDataMessage.
  ///
  /// In en, this message translates to:
  /// **'This action deletes all your transactions and custom categories.\nConfirm with your password.'**
  String get resetDataMessage;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Data reset.'**
  String get resetDone;

  /// No description provided for @resetDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to reset data.'**
  String get resetDataFailed;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @defaultUserEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get defaultUserEmail;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategory;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get enterCategoryName;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. Do you want to continue?'**
  String get deleteAccountMessage;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed. Try again later.'**
  String get deleteFailed;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @feedbackType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get feedbackType;

  /// No description provided for @feedbackBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get feedbackBug;

  /// No description provided for @feedbackSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Improvement suggestion'**
  String get feedbackSuggestion;

  /// No description provided for @feedbackComment.
  ///
  /// In en, this message translates to:
  /// **'General comment'**
  String get feedbackComment;

  /// No description provided for @feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get feedbackMessage;

  /// No description provided for @feedbackMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get feedbackMessageRequired;

  /// No description provided for @feedbackMessageShort.
  ///
  /// In en, this message translates to:
  /// **'Message too short'**
  String get feedbackMessageShort;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback.'**
  String get feedbackThanks;

  /// No description provided for @feedbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to send. Try again later.'**
  String get feedbackFailed;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get passwordUpdated;

  /// No description provided for @passwordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update password.'**
  String get passwordUpdateFailed;

  /// No description provided for @externalProviderReset.
  ///
  /// In en, this message translates to:
  /// **'Signed in via external provider. Use that provider to reset your account.'**
  String get externalProviderReset;

  /// No description provided for @externalProviderChange.
  ///
  /// In en, this message translates to:
  /// **'Signed in via external provider. Change password from that provider.'**
  String get externalProviderChange;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @expenseAlerts.
  ///
  /// In en, this message translates to:
  /// **'Spending alerts'**
  String get expenseAlerts;

  /// No description provided for @weeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly report'**
  String get weeklyReport;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Summary every Monday'**
  String get weeklySummary;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get defaultCurrency;

  /// No description provided for @validateCurrency.
  ///
  /// In en, this message translates to:
  /// **'Validate currency'**
  String get validateCurrency;

  /// No description provided for @currencyUpdatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversion in progress'**
  String get currencyUpdatingTitle;

  /// No description provided for @currencyUpdatingBody.
  ///
  /// In en, this message translates to:
  /// **'Updating currency...'**
  String get currencyUpdatingBody;

  /// No description provided for @currencyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Currency updated.'**
  String get currencyUpdated;

  /// No description provided for @currencyUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update.'**
  String get currencyUpdateFailed;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get darkModeLight;

  /// No description provided for @darkModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkModeDark;

  /// No description provided for @weeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get weeklySummaryTitle;

  /// No description provided for @noWeeklyTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions this week.'**
  String get noWeeklyTransactions;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category: {category}'**
  String topCategory(Object category);

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @resetMyData.
  ///
  /// In en, this message translates to:
  /// **'Reset my data'**
  String get resetMyData;

  /// No description provided for @resetMyDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletes all transactions and categories.'**
  String get resetMyDataSubtitle;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @sendFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report a bug or suggest an improvement.'**
  String get sendFeedbackSubtitle;

  /// No description provided for @signInToSeeProfile.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your profile.'**
  String get signInToSeeProfile;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @enterOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your old password'**
  String get enterOldPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get enterNewPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the password'**
  String get confirmPasswordRequired;

  /// No description provided for @reauthenticateToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please reauthenticate to continue.'**
  String get reauthenticateToContinue;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @noExpenseThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses for this month.'**
  String get noExpenseThisMonth;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period.'**
  String get noDataForPeriod;

  /// No description provided for @weeklySummaryRange.
  ///
  /// In en, this message translates to:
  /// **'From {start} to {end}'**
  String weeklySummaryRange(Object end, Object start);

  /// No description provided for @oldPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Old password is incorrect.'**
  String get oldPasswordIncorrect;

  /// No description provided for @emailAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'Email already in use.'**
  String get emailAlreadyUsed;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get invalidEmail;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get genericError;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your budget easily'**
  String get appTagline;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take control of your finances.'**
  String get loginSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountQuestion;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get resetPasswordSent;

  /// No description provided for @resetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to send the email.'**
  String get resetPasswordFailed;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerTitle;

  /// No description provided for @registerHeader.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerHeader;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your expenses and income.'**
  String get registerSubtitle;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @termsAccept.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our terms.'**
  String get termsAccept;

  /// No description provided for @alreadyRegisteredQuestion.
  ///
  /// In en, this message translates to:
  /// **'Already registered?'**
  String get alreadyRegisteredQuestion;

  /// No description provided for @signInToManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your categories.'**
  String get signInToManageCategories;

  /// No description provided for @globalCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Global categories'**
  String get globalCategoriesTitle;

  /// No description provided for @myCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'My categories'**
  String get myCategoriesTitle;

  /// No description provided for @noGlobalCategories.
  ///
  /// In en, this message translates to:
  /// **'No global categories available right now.'**
  String get noGlobalCategories;

  /// No description provided for @noUserCategories.
  ///
  /// In en, this message translates to:
  /// **'No custom categories. Add one!'**
  String get noUserCategories;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategoryTitle;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryWarning.
  ///
  /// In en, this message translates to:
  /// **'Make sure this category is not in use.'**
  String get deleteCategoryWarning;

  /// No description provided for @adminNoGlobalCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories.'**
  String get adminNoGlobalCategories;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @unknownValue.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownValue;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminGlobalCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Global categories'**
  String get adminGlobalCategoriesTitle;

  /// No description provided for @adminGlobalCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, edit, delete'**
  String get adminGlobalCategoriesSubtitle;

  /// No description provided for @adminGlobalStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Global statistics'**
  String get adminGlobalStatsTitle;

  /// No description provided for @adminGlobalStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System overview'**
  String get adminGlobalStatsSubtitle;

  /// No description provided for @adminManageUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'User management'**
  String get adminManageUsersTitle;

  /// No description provided for @adminManageUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Roles and deletion'**
  String get adminManageUsersSubtitle;

  /// No description provided for @adminFeedbacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get adminFeedbacksTitle;

  /// No description provided for @adminFeedbacksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bugs and suggestions'**
  String get adminFeedbacksSubtitle;

  /// No description provided for @adminFeedbackLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load feedback.'**
  String get adminFeedbackLoadFailed;

  /// No description provided for @adminNoFeedbacks.
  ///
  /// In en, this message translates to:
  /// **'No feedback yet.'**
  String get adminNoFeedbacks;

  /// No description provided for @adminStatsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics.'**
  String get adminStatsLoadFailed;

  /// No description provided for @adminStatsLoadFailedHint.
  ///
  /// In en, this message translates to:
  /// **'Check admin role and published rules.'**
  String get adminStatsLoadFailedHint;

  /// No description provided for @adminStatsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data detected. Check admin role, published rules, and Firebase project.'**
  String get adminStatsNoData;

  /// No description provided for @usersLabel.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersLabel;

  /// No description provided for @adminsLabel.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get adminsLabel;

  /// No description provided for @adminNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users.'**
  String get adminNoUsers;

  /// No description provided for @adminSignedUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Signed up:'**
  String get adminSignedUpLabel;

  /// No description provided for @adminDeleteSelfFailed.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete your own account.'**
  String get adminDeleteSelfFailed;

  /// No description provided for @adminRevokeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Revoke admin'**
  String get adminRevokeAdmin;

  /// No description provided for @adminMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get adminMakeAdmin;

  /// No description provided for @adminDeleteUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get adminDeleteUserTitle;

  /// No description provided for @adminDeleteUserWarning.
  ///
  /// In en, this message translates to:
  /// **'This action only deletes the Firestore profile.'**
  String get adminDeleteUserWarning;

  /// No description provided for @adminSearchByEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by email'**
  String get adminSearchByEmail;

  /// No description provided for @filterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterLabel;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get sortRecent;

  /// No description provided for @sortOld.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOld;

  /// No description provided for @detailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details:'**
  String get detailsLabel;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportSelectRange.
  ///
  /// In en, this message translates to:
  /// **'Select a period'**
  String get exportSelectRange;

  /// No description provided for @exportNoData.
  ///
  /// In en, this message translates to:
  /// **'No data for the selected period.'**
  String get exportNoData;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'CSV files saved.'**
  String get exportSaved;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed.'**
  String get exportFailed;

  /// No description provided for @exportSummarySheet.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get exportSummarySheet;

  /// No description provided for @exportDetailsSheet.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get exportDetailsSheet;

  /// No description provided for @exportStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get exportStart;

  /// No description provided for @exportEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get exportEnd;

  /// No description provided for @exportTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get exportTotalIncome;

  /// No description provided for @exportTotalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get exportTotalExpense;

  /// No description provided for @exportBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get exportBalance;

  /// No description provided for @exportTransactionsCount.
  ///
  /// In en, this message translates to:
  /// **'Transactions count'**
  String get exportTransactionsCount;

  /// No description provided for @exportMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get exportMonthLabel;

  /// No description provided for @exportDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get exportDate;

  /// No description provided for @exportTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get exportTime;

  /// No description provided for @exportType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exportType;

  /// No description provided for @exportCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get exportCategory;

  /// No description provided for @exportAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get exportAmount;

  /// No description provided for @exportCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get exportCurrency;

  /// No description provided for @exportOriginalCurrency.
  ///
  /// In en, this message translates to:
  /// **'Original currency'**
  String get exportOriginalCurrency;

  /// No description provided for @exportRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get exportRate;

  /// No description provided for @exportNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get exportNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
