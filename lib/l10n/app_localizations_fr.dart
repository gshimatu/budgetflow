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

  @override
  String get transactions => 'Transactions';

  @override
  String get signInToSeeTransactions =>
      'Connectez-vous pour voir vos transactions.';

  @override
  String get noTransactionsRecorded => 'Aucune transaction enregistree.';

  @override
  String get filterTransactions => 'Filtrer les transactions';

  @override
  String get filterAll => 'Toutes';

  @override
  String get filterToday => 'Aujourd\'hui';

  @override
  String get filterPickDay => 'Choisir un jour';

  @override
  String get filterWeek => 'Cette semaine';

  @override
  String get filterMonth => 'Ce mois';

  @override
  String get filterYear => 'Cette annee';

  @override
  String get emptyToday => 'Aucune transaction aujourd\'hui.';

  @override
  String get emptyDay => 'Aucune transaction pour ce jour.';

  @override
  String get emptyWeek => 'Aucune transaction cette semaine.';

  @override
  String get emptyMonth => 'Aucune transaction ce mois.';

  @override
  String get emptyYear => 'Aucune transaction cette annee.';

  @override
  String get emptyAll => 'Aucune transaction enregistree.';

  @override
  String get deleteTransactionTitle => 'Supprimer la transaction';

  @override
  String get deleteTransactionMessage =>
      'Voulez-vous vraiment supprimer cette transaction ?';

  @override
  String filterDayLabel(Object date) {
    return 'Jour : $date';
  }

  @override
  String get confirmDelete => 'Supprimer';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get newTransaction => 'Nouvelle transaction';

  @override
  String get editTransaction => 'Modifier la transaction';

  @override
  String get type => 'Type';

  @override
  String get expense => 'Depense';

  @override
  String get category => 'Categorie';

  @override
  String get other => 'Autre';

  @override
  String get categoryName => 'Nom de la categorie';

  @override
  String get noteOptional => 'Note (optionnel)';

  @override
  String get date => 'Date';

  @override
  String get choose => 'Choisir';

  @override
  String amountEquivalent(Object amount) {
    return 'Equivalent : $amount';
  }

  @override
  String get converting => 'Conversion en cours...';

  @override
  String get invalidRate => 'Taux invalide';

  @override
  String get saveFailed => 'Impossible d\'enregistrer.';

  @override
  String get transactionSaveFailed =>
      'Impossible d\'enregistrer la transaction.';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get signInToSeeStats => 'Connectez-vous pour voir vos statistiques.';

  @override
  String get statsNoTransactions => 'Aucune transaction pour le moment.';

  @override
  String get expensesBreakdown => 'Repartition des depenses';

  @override
  String get monthlyEvolution => 'Evolution mensuelle';

  @override
  String get dailyExpenseTrendTitle =>
      'Tendance (polygone) - Depenses journaliere';

  @override
  String get monthLabel => 'Mois';

  @override
  String get yearLabel => 'Annee';

  @override
  String get balanceLabel => 'Solde';

  @override
  String get monthlyEvolutionNote =>
      'Evolution sur les 6 derniers mois affiches.';

  @override
  String get dailyEvolutionNote =>
      'Evolution quotidienne des depenses pour le mois selectionne.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get fullName => 'Nom complet';

  @override
  String get emailLabel => 'Email';

  @override
  String get updateProfile => 'Mettre a jour';

  @override
  String get profileUpdated => 'Profil mis a jour.';

  @override
  String get verifyEmailSent =>
      'Un email de verification a ete envoye. Validez-le pour changer votre email.';

  @override
  String get profileUpdateFailed => 'Impossible de mettre a jour le profil.';

  @override
  String get userNotSignedIn => 'Utilisateur non connecte.';

  @override
  String get resetDataTitle => 'Reinitialiser les donnees';

  @override
  String get resetDataMessage =>
      'Cette action supprime toutes vos transactions et categories personnalisees.\nConfirmez avec votre mot de passe.';

  @override
  String get password => 'Mot de passe';

  @override
  String get reset => 'Reinitialiser';

  @override
  String get resetDone => 'Donnees reinitialisees.';

  @override
  String get resetDataFailed => 'Impossible de reinitialiser les donnees.';

  @override
  String get defaultUserName => 'Utilisateur';

  @override
  String get defaultUserEmail => 'Pas d\'email';

  @override
  String get selectCategory => 'Veuillez selectionner une categorie';

  @override
  String get enterCategoryName => 'Veuillez saisir un nom de categorie';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountMessage =>
      'Cette action est irreversible. Voulez-vous continuer ?';

  @override
  String get deleteFailed => 'Suppression impossible. Reessaie plus tard.';

  @override
  String get sendFeedback => 'Envoyer un commentaire';

  @override
  String get feedbackType => 'Type';

  @override
  String get feedbackBug => 'Signaler un bug';

  @override
  String get feedbackSuggestion => 'Suggestion d\'amelioration';

  @override
  String get feedbackComment => 'Commentaire general';

  @override
  String get feedbackMessage => 'Votre message';

  @override
  String get feedbackMessageRequired => 'Veuillez saisir un message';

  @override
  String get feedbackMessageShort => 'Message trop court';

  @override
  String get feedbackThanks => 'Merci pour votre retour.';

  @override
  String get feedbackFailed => 'Envoi impossible. Reessaie plus tard.';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get oldPassword => 'Ancien mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordTooShort => 'Mot de passe trop court';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordUpdated => 'Mot de passe mis a jour.';

  @override
  String get passwordUpdateFailed =>
      'Impossible de mettre a jour le mot de passe.';

  @override
  String get externalProviderReset =>
      'Connexion via un fournisseur externe. Utilisez ce fournisseur pour reinitialiser votre compte.';

  @override
  String get externalProviderChange =>
      'Connexion via un fournisseur externe. Changez le mot de passe depuis ce fournisseur.';

  @override
  String get signOut => 'Se deconnecter';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get expenseAlerts => 'Alertes sur vos depenses';

  @override
  String get weeklyReport => 'Rapport hebdo';

  @override
  String get weeklySummary => 'Resume chaque lundi';

  @override
  String get defaultCurrency => 'Devise par defaut';

  @override
  String get validateCurrency => 'Valider la devise';

  @override
  String get currencyUpdatingTitle => 'Conversion en cours';

  @override
  String get currencyUpdatingBody => 'Mise a jour de la devise...';

  @override
  String get currencyUpdated => 'Devise mise a jour.';

  @override
  String get currencyUpdateFailed => 'Mise a jour impossible.';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get darkModeLight => 'Clair';

  @override
  String get darkModeDark => 'Sombre';

  @override
  String get weeklySummaryTitle => 'Resume hebdomadaire';

  @override
  String get noWeeklyTransactions => 'Aucune transaction cette semaine.';

  @override
  String topCategory(Object category) {
    return 'Categorie principale : $category';
  }

  @override
  String get security => 'Securite';

  @override
  String get resetMyData => 'Reinitialiser mes donnees';

  @override
  String get resetMyDataSubtitle =>
      'Supprime toutes les transactions et categories.';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get comments => 'Commentaires';

  @override
  String get sendFeedbackSubtitle =>
      'Signaler un bug ou proposer une amelioration.';

  @override
  String get signInToSeeProfile => 'Connectez-vous pour voir votre profil.';

  @override
  String get send => 'Envoyer';

  @override
  String get enterPassword => 'Veuillez saisir votre mot de passe';

  @override
  String get enterOldPassword => 'Veuillez saisir l\'ancien mot de passe';

  @override
  String get enterNewPassword => 'Veuillez saisir un nouveau mot de passe';

  @override
  String get confirmPasswordRequired => 'Veuillez confirmer le mot de passe';

  @override
  String get reauthenticateToContinue =>
      'Veuillez vous reconnecter pour continuer.';

  @override
  String get enterName => 'Veuillez saisir votre nom';

  @override
  String get enterEmail => 'Veuillez saisir votre email';

  @override
  String get noExpenseThisMonth => 'Aucune depense pour ce mois.';

  @override
  String get noDataForPeriod => 'Aucune donnee pour cette periode.';

  @override
  String weeklySummaryRange(Object end, Object start) {
    return 'Du $start au $end';
  }

  @override
  String get oldPasswordIncorrect => 'L\'ancien mot de passe est incorrect.';

  @override
  String get emailAlreadyUsed => 'Email deja utilisee.';

  @override
  String get invalidEmail => 'Adresse email invalide.';

  @override
  String get genericError => 'Une erreur est survenue.';

  @override
  String get appTagline => 'Gerer votre budget facilement';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitle => 'Reprenez le controle de vos finances.';

  @override
  String get forgotPassword => 'Mot de passe oublie ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get noAccountQuestion => 'Pas de compte ?';

  @override
  String get createAccount => 'Creer un compte';

  @override
  String get resetPasswordTitle => 'Reinitialiser le mot de passe';

  @override
  String get resetPasswordSent => 'Email de reinitialisation envoye.';

  @override
  String get resetPasswordFailed => 'Impossible d\'envoyer l\'email.';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get registerHeader => 'Creer votre compte';

  @override
  String get registerSubtitle => 'Commencez a suivre vos depenses et revenus.';

  @override
  String get signUpWithGoogle => 'S\'inscrire avec Google';

  @override
  String get termsAccept =>
      'En creant un compte, vous acceptez nos conditions.';

  @override
  String get alreadyRegisteredQuestion => 'Deja inscrit ?';

  @override
  String get signInToManageCategories =>
      'Connectez-vous pour gerer vos categories.';

  @override
  String get globalCategoriesTitle => 'Categories globales';

  @override
  String get myCategoriesTitle => 'Mes categories';

  @override
  String get noGlobalCategories =>
      'Aucune categorie globale disponible pour le moment.';

  @override
  String get noUserCategories =>
      'Aucune categorie personnalisee. Ajoutez-en une !';

  @override
  String get newCategory => 'Nouvelle categorie';

  @override
  String get editCategoryTitle => 'Modifier la categorie';

  @override
  String get deleteCategoryTitle => 'Supprimer la categorie';

  @override
  String get deleteCategoryWarning =>
      'Assurez-vous que cette categorie n\'est pas utilisee.';

  @override
  String get adminNoGlobalCategories => 'Aucune categorie.';

  @override
  String get unknownDate => 'Date inconnue';

  @override
  String get unknownValue => 'Inconnu';

  @override
  String get adminDashboardTitle => 'Tableau de bord';

  @override
  String get adminGlobalCategoriesTitle => 'Categories globales';

  @override
  String get adminGlobalCategoriesSubtitle => 'Creer, modifier, supprimer';

  @override
  String get adminGlobalStatsTitle => 'Statistiques globales';

  @override
  String get adminGlobalStatsSubtitle => 'Vue d\'ensemble du systeme';

  @override
  String get adminManageUsersTitle => 'Gestion des utilisateurs';

  @override
  String get adminManageUsersSubtitle => 'Roles et suppression';

  @override
  String get adminFeedbacksTitle => 'Commentaires';

  @override
  String get adminFeedbacksSubtitle => 'Bugs et suggestions';

  @override
  String get adminFeedbackLoadFailed =>
      'Impossible de charger les commentaires.';

  @override
  String get adminNoFeedbacks => 'Aucun commentaire pour le moment.';

  @override
  String get adminStatsLoadFailed => 'Erreur de chargement des statistiques.';

  @override
  String get adminStatsLoadFailedHint =>
      'Verifie le role admin et les regles publiees.';

  @override
  String get adminStatsNoData =>
      'Aucune donnee detectee. Verifie le role admin, les regles publiees et le projet Firebase utilise.';

  @override
  String get usersLabel => 'Utilisateurs';

  @override
  String get adminsLabel => 'Admins';

  @override
  String get adminNoUsers => 'Aucun utilisateur.';

  @override
  String get adminSignedUpLabel => 'Inscrit :';

  @override
  String get adminDeleteSelfFailed => 'Impossible de supprimer votre compte.';

  @override
  String get adminRevokeAdmin => 'Revoquer admin';

  @override
  String get adminMakeAdmin => 'Passer admin';

  @override
  String get adminDeleteUserTitle => 'Supprimer l\'utilisateur';

  @override
  String get adminDeleteUserWarning =>
      'Cette action supprime uniquement le profil Firestore.';

  @override
  String get adminSearchByEmail => 'Rechercher par email';

  @override
  String get filterLabel => 'Filtre';

  @override
  String get orderLabel => 'Ordre';

  @override
  String get sortRecent => 'Recent';

  @override
  String get sortOld => 'Ancien';

  @override
  String get detailsLabel => 'Details :';

  @override
  String get exportCsv => 'Exporter CSV';

  @override
  String get exportSelectRange => 'Choisir une periode';

  @override
  String get exportNoData => 'Aucune donnee pour la periode selectionnee.';

  @override
  String get exportSaved => 'Fichiers CSV enregistres.';

  @override
  String get exportFailed => 'Echec de l\'export.';

  @override
  String get exportSummarySheet => 'Resume';

  @override
  String get exportDetailsSheet => 'Details';

  @override
  String get exportStart => 'Debut';

  @override
  String get exportEnd => 'Fin';

  @override
  String get exportTotalIncome => 'Total revenus';

  @override
  String get exportTotalExpense => 'Total depenses';

  @override
  String get exportBalance => 'Solde';

  @override
  String get exportTransactionsCount => 'Nombre de transactions';

  @override
  String get exportMonthLabel => 'Mois';

  @override
  String get exportDate => 'Date';

  @override
  String get exportTime => 'Heure';

  @override
  String get exportType => 'Type';

  @override
  String get exportCategory => 'Categorie';

  @override
  String get exportAmount => 'Montant';

  @override
  String get exportCurrency => 'Devise';

  @override
  String get exportOriginalCurrency => 'Devise d\'origine';

  @override
  String get exportRate => 'Taux';

  @override
  String get exportNote => 'Note';

  @override
  String get exportPreviewTitle => 'Apercu de l\'export';

  @override
  String get exportPreviewRange => 'Periode';

  @override
  String get exportPreviewSummary => 'Lignes resume';

  @override
  String get exportPreviewDetails => 'Lignes details';

  @override
  String get exportSaveLocation => 'Enregistre dans';

  @override
  String get exportStartExport => 'Exporter';

  @override
  String get exportCancel => 'Annuler';
}
