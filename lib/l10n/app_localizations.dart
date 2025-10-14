import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en'),
  ];

  /// The title of the import glossary dialog
  ///
  /// In de, this message translates to:
  /// **'Glossar importieren'**
  String get importGlossary;

  /// The label of the name of the glossary field
  ///
  /// In de, this message translates to:
  /// **'Name des Glossars'**
  String get nameOfGlossary;

  /// The hint of the name of the glossary field
  ///
  /// In de, this message translates to:
  /// **'z.B. Glossar 1'**
  String get hintNameOfGlossary;

  /// The error message when the glossary already exists
  ///
  /// In de, this message translates to:
  /// **'Glossar existiert bereits'**
  String get glossaryAlreadyExists;

  /// The label of the cancel button
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// The label of the import button
  ///
  /// In de, this message translates to:
  /// **'Importieren'**
  String get import;

  /// The label of the choose file to import button
  ///
  /// In de, this message translates to:
  /// **'Datei zum Importieren auswählen'**
  String get chooseFileToImport;

  /// The label of the choose file button
  ///
  /// In de, this message translates to:
  /// **'Datei auswählen'**
  String get chooseFile;

  /// The error message when the file is unsupported or already exists
  ///
  /// In de, this message translates to:
  /// **'Datei wird nicht unterstützt oder existiert bereits'**
  String get fileUnsupportedOrAlreadyExists;

  /// The label of the add glossary button
  ///
  /// In de, this message translates to:
  /// **'Erstelle ein {isShared, select, local{lokales} shared{gemeinsames} other{}} Glossar'**
  String addGlossary(String isShared);

  /// The error message when the name is invalid
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen gültigen Namen ein'**
  String get enterValidName;

  /// The label of the submit button
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get submit;

  /// The title of the glossary list
  ///
  /// In de, this message translates to:
  /// **'Glossar Liste'**
  String get glossaryList;

  /// The label of the delete button
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// The label of the create local glossary button
  ///
  /// In de, this message translates to:
  /// **'Lokales Glossar erstellen'**
  String get createLocalGlossary;

  /// The label of the create shared glossary button
  ///
  /// In de, this message translates to:
  /// **'Gemeinsames Glossar erstellen'**
  String get createSharedGlossary;

  /// The question when the user wants to leave the shared glossary
  ///
  /// In de, this message translates to:
  /// **'Möchtest du aus dem synchronisierten Glossar austreten?'**
  String get leaveGlossaryQuestion;

  /// The question when the user wants to delete the glossary
  ///
  /// In de, this message translates to:
  /// **'Möchtest du das Glossar und alle Einträge löschen?'**
  String get deleteGlossaryQuestion;

  /// The label of the leave button
  ///
  /// In de, this message translates to:
  /// **'Verlassen'**
  String get leave;

  /// The label of the join shared glossary button
  ///
  /// In de, this message translates to:
  /// **'Gemeinsamen Glossar beitreten'**
  String get joinSharedGlossary;

  /// The label of the enter join code field
  ///
  /// In de, this message translates to:
  /// **'Geben Sie den Beitrittscode ein'**
  String get enterJoinCode;

  /// The error message when the join code is wrong
  ///
  /// In de, this message translates to:
  /// **'Der Beitrittscode ist ungültig'**
  String get invalidJoinCode;

  /// The label of the join code field
  ///
  /// In de, this message translates to:
  /// **'Beitrittscode'**
  String get joinCode;

  /// The label of the title increasing sort option
  ///
  /// In de, this message translates to:
  /// **'Titel (A-Z)'**
  String get sortOptionTitleIncreasing;

  /// The label of the title decreasing sort option
  ///
  /// In de, this message translates to:
  /// **'Titel (Z-A)'**
  String get sortOptionTitleDecreasing;

  /// The label of the author increasing sort option
  ///
  /// In de, this message translates to:
  /// **'Author (A-Z)'**
  String get sortOptionAuthorIncreasing;

  /// The label of the author decreasing sort option
  ///
  /// In de, this message translates to:
  /// **'Author (Z-A)'**
  String get sortOptionAuthorDecreasing;

  /// The label of the add entry button
  ///
  /// In de, this message translates to:
  /// **'Füge einen Eintrag hinzu'**
  String get addEntry;

  /// The label of the select glossary button
  ///
  /// In de, this message translates to:
  /// **'Wähle ein Glossar'**
  String get selectGlossary;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
