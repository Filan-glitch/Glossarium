import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../models/glossar.dart';
import '../redux/state.dart';

class ImportExternDialog extends StatefulWidget {
  final Glossar? glossar;
  
  const ImportExternDialog({super.key, this.glossar});

  @override
  State<ImportExternDialog> createState() => _ImportExternDialogState();
}

class _ImportExternDialogState extends State<ImportExternDialog> {
  final _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importiere Glossar'),
      content: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Name des Glossars',
              hintText: 'z.B. Glossar 1',
            ),
          ),
          const SizedBox(height: 20),
          StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return Visibility(
                visible: _controller.text.isNotEmpty && (state.glossars.any((element) => element.title == _controller.text)),
                child: const Text('Das Glossar existiert schon.'),
              );
            }
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return TextButton(
              onPressed: (_controller.text.isNotEmpty && (state.glossars.any((element) => element.title == _controller.text))) ? null : () {
                Navigator.of(context).pop(widget.glossar?.copyWith(title: _controller.text));
              },
              child: const Text('Importieren'),
            );
          },
        ),
      ],
    );
  }
}
