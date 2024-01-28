import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../models/glossar.dart';
import '../models/glossar_entry.dart';
import '../redux/state.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  FilePickerResult? _result;
  bool? _valid;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importiere Glossar'),
      content: Column(
        children: [
          const Text('Wähle eine Datei aus, um sie zu importieren.'),
          const SizedBox(height: 20),
          StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () async {
                  _result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['csv']
                  );

                  if(_result == null) {
                    setState(() => _valid = false);
                    return;
                  }

                  if(state.glossars.any((glossar) => glossar.title == _result!.files.single.name.replaceAll('.csv', ''))) {
                    setState(() => _valid = false);
                    return;
                  }

                  File file = File(_result!.files.single.path!);
                  List<String> lines = file.readAsLinesSync();

                  if(lines.isEmpty) {
                    setState(() => _valid = false);
                    return;
                  }

                  List<String> header = lines[0].split(';');
                  setState(() => _valid = header.length == 2 && header[0] == 'Begriff' && header[1] == 'Beschreibung');

                  for(var line in lines.sublist(1)) {
                    List<String> row = line.split(';');
                    if(row.length != 2 || row[0].isEmpty || row[1].isEmpty || row[0].length > 50 || row[1].length > 500 || row[0].contains(';') || row[1].contains(';') || row[0].contains('\\')) {
                      setState(() => _valid = false);
                      return;
                    }
                  }
                },
                child: Text(_result?.files.single.name ?? 'Datei auswählen'),
              );
            },
          ),
          Visibility(
            visible: !(_valid ?? true),
              child: const Text('Die Datei ist ungültig oder Glossar existiert schon.', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: (_valid == null || !_valid!) ? null : () {
            Glossar glossar = Glossar(
              title: _result!.files.single.name.replaceAll('.csv', ''),
            );

            File file = File(_result!.files.single.path!);
            List<String> lines = file.readAsLinesSync();

            for(var line in lines.sublist(1)) {
              List<String> row = line.split(';');
              glossar = glossar.copyWith(
                entries: glossar.entries + [GlossarEntry(
                  title: row[0],
                  description: row[1],
                )],
              );
            }

            Navigator.of(context).pop(glossar);
          },
          child: const Text('Importieren'),
        ),
      ],
    );
  }
}
