import 'package:flutter/services.dart';

import '../models/glossar.dart';
import '../models/glossar_entry.dart';

const _methodChannel = MethodChannel('glossarium.process.csv');

Future<Glossar?> getImportData() async {
  final data = await _methodChannel.invokeMethod('getCSV');
  if(data == null) return null;

  final List<String> lines = (data as String).split('\n');
  if(lines.isEmpty || lines[0] != 'Begriff;Beschreibung') return null;

  final List<GlossarEntry> entries = [];
  lines.sublist(1).forEach((line) {
    final List<String> row = line.split(';');
    if(row.length == 2 && row[0].isNotEmpty && row[1].isNotEmpty && !entries.any((element) => element.title == row[0]) && !row[0].contains('\\')) {
      entries.add(GlossarEntry(title: row[0], description: row[1]));
    }
  });

  return Glossar(entries: entries, title: '');
}

