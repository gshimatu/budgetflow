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
}
