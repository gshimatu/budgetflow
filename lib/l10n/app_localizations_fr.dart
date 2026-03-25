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
}
