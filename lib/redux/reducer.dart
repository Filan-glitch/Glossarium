import 'package:glossarium/models/glossar_entry.dart';

import '../models/glossar.dart';
import 'actions.dart';
import 'state.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is! Action) {
    return state;
  }
  switch (action.type) {
    case ActionTypes.clear:
      return AppState();
    case ActionTypes.addGlossary:
      return AppState(glossars: List.from(state.glossars)..add(action.payload));
    case ActionTypes.addGlossaryItem:
      return AppState(
        glossars: state.glossars.map((glossar) {
          if (glossar.title == action.payload['glossary']) {
            return glossar.copyWith(
              entries: List.from(glossar.entries)
                ..add(GlossarEntry.fromMap(action.payload)),
            );
          }
          return glossar;
        }).toList(),
      );
    case ActionTypes.loadGlossarys:
      return AppState(glossars: action.payload);
    case ActionTypes.loadGlossaryEntrys:
      return AppState(
        glossars: state.glossars.map((glossar) {
          final payload = action.payload as List<Map<String, dynamic>>;
          final List<GlossarEntry> entries = [];
          for (var entry in payload
              .where((element) => element['glossary'] == glossar.title)) {
            entries.add(GlossarEntry.fromMap(entry));
          }
          glossar = glossar.copyWith(entries: entries);
          return glossar;
        }).toList(),
      );
    case ActionTypes.removeGlossary:
      return AppState(
          glossars: state.glossars
              .where((glossar) => glossar.title != action.payload.title)
              .toList());
    case ActionTypes.updateGlossaryItem:
      return AppState(
        glossars: state.glossars.map((glossar) {
          if (glossar.title == action.payload['glossary']) {
            return glossar.copyWith(
              entries: glossar.entries.map((entry) {
                if (entry.title == action.payload['title']) {
                  return GlossarEntry.fromMap(action.payload);
                }
                return entry;
              }).toList(),
            );
          }
          return glossar;
        }).toList(),
      );
    case ActionTypes.updateGlossary:
      return AppState(
        glossars: state.glossars.map((glossar) {
          if (glossar.title == action.payload.title) {
            return action.payload as Glossar;
          }
          return glossar;
        }).toList(),
      );
    case ActionTypes.removeGlossaryItem:
      return AppState(
        glossars: state.glossars.map((glossar) {
          if (glossar.title == action.payload['glossary']) {
            return glossar.copyWith(
              entries: glossar.entries
                  .where((entry) =>
                      entry.title != action.payload['title'] as String)
                  .toList(),
            );
          }
          return glossar;
        }).toList(),
      );
    default:
      return state;
  }
}
