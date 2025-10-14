import 'package:glossarium/l10n/app_localizations.dart'; // ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get importGlossary => AppLocalizations.of(context)!.importGlossary;

  @override
  String get nameOfGlossary => AppLocalizations.of(context)!.nameOfGlossary;

  @override
  String get hintNameOfGlossary =>
      AppLocalizations.of(context)!.hintNameOfGlossary;

  @override
  String get glossaryAlreadyExists =>
      AppLocalizations.of(context)!.glossaryAlreadyExists;

  @override
  String get cancel => AppLocalizations.of(context)!.cancel;

  @override
  String get import => AppLocalizations.of(context)!.import;

  @override
  String get chooseFileToImport =>
      AppLocalizations.of(context)!.chooseFileToImport;

  @override
  String get chooseFile => AppLocalizations.of(context)!.chooseFile;

  @override
  String get fileUnsupportedOrAlreadyExists =>
      AppLocalizations.of(context)!.fileUnsupportedOrAlreadyExists;

  @override
  String addGlossary(String isShared) {
    String _temp0 = intl.Intl.selectLogic(isShared, {
      'local': 'lokales',
      'shared': 'gemeinsames',
      'other': '',
    });
    return 'Erstelle ein $_temp0 Glossar';
  }

  @override
  String get enterValidName => AppLocalizations.of(context)!.enterValidName;

  @override
  String get submit => AppLocalizations.of(context)!.submit;

  @override
  String get glossaryList => AppLocalizations.of(context)!.glossaryList;

  @override
  String get delete => AppLocalizations.of(context)!.delete;

  @override
  String get createLocalGlossary =>
      AppLocalizations.of(context)!.createLocalGlossary;

  @override
  String get createSharedGlossary =>
      AppLocalizations.of(context)!.createSharedGlossary;

  @override
  String get leaveGlossaryQuestion =>
      AppLocalizations.of(context)!.leaveGlossaryQuestion;

  @override
  String get deleteGlossaryQuestion =>
      AppLocalizations.of(context)!.deleteGlossaryQuestion;

  @override
  String get leave => AppLocalizations.of(context)!.leave;

  @override
  String get joinSharedGlossary =>
      AppLocalizations.of(context)!.joinSharedGlossary;

  @override
  String get enterJoinCode => AppLocalizations.of(context)!.enterJoinCode;

  @override
  String get invalidJoinCode => AppLocalizations.of(context)!.invalidJoinCode;

  @override
  String get joinCode => AppLocalizations.of(context)!.joinCode;

  @override
  String get sortOptionTitleIncreasing =>
      AppLocalizations.of(context)!.sortOptionTitleIncreasing;

  @override
  String get sortOptionTitleDecreasing =>
      AppLocalizations.of(context)!.sortOptionTitleDecreasing;

  @override
  String get sortOptionAuthorIncreasing =>
      AppLocalizations.of(context)!.sortOptionAuthorIncreasing;

  @override
  String get sortOptionAuthorDecreasing =>
      AppLocalizations.of(context)!.sortOptionAuthorDecreasing;

  @override
  String get addEntry => AppLocalizations.of(context)!.addEntry;

  @override
  String get selectGlossary => AppLocalizations.of(context)!.selectGlossary;
}
