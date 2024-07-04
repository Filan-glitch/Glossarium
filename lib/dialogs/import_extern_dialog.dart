import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      title: Text(AppLocalizations.of(context)!.importGlossary),
      content: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.nameOfGlossary,
              hintText: AppLocalizations.of(context)!.hintNameOfGlossary,
            ),
          ),
          const SizedBox(height: 20),
          StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return Visibility(
                visible: _controller.text.isNotEmpty && (state.glossars.any((element) => element.title == _controller.text)),
                child: Text(AppLocalizations.of(context)!.glossaryAlreadyExists),
              );
            }
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return TextButton(
              onPressed: (_controller.text.isNotEmpty && (state.glossars.any((element) => element.title == _controller.text))) ? null : () {
                Navigator.of(context).pop(widget.glossar?.copyWith(title: _controller.text));
              },
              child: Text(AppLocalizations.of(context)!.import),
            );
          },
        ),
      ],
    );
  }
}
