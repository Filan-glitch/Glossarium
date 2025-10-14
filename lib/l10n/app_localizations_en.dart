import 'package:glossarium/l10n/app_localizations.dart'; // ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get importGlossary => 'Import glossary';

  @override
  String get nameOfGlossary => 'Name of the glossary';

  @override
  String get hintNameOfGlossary => 'e.g. Glossary 1';

  @override
  String get glossaryAlreadyExists => 'Glossary already exists';

  @override
  String get cancel => 'Cancel';

  @override
  String get import => 'Import';

  @override
  String get chooseFileToImport => 'Choose file to import';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get fileUnsupportedOrAlreadyExists =>
      'File unsupported or already exists';

  @override
  String addGlossary(String isShared) {
    String _temp0 = intl.Intl.selectLogic(isShared, {
      'local': 'local',
      'shared': 'shared',
      'other': '',
    });
    return 'Add a $_temp0 glossary';
  }

  @override
  String get enterValidName => 'Enter a valid name';

  @override
  String get submit => 'Submit';

  @override
  String get glossaryList => 'Glossary List';

  @override
  String get delete => 'Delete';

  @override
  String get createLocalGlossary => 'Create local glossary';

  @override
  String get createSharedGlossary => 'Create shared glossary';

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
  String get sortOptionTitleIncreasing => 'Title (A-Z)';

  @override
  String get sortOptionTitleDecreasing => 'Title (Z-A)';

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
