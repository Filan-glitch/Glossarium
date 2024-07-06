import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:glossarium/dialogs/import_dialog.dart';
import 'package:glossarium/dialogs/import_extern_dialog.dart';
import 'package:glossarium/services/import.dart';
import 'package:glossarium/storage/firestore.dart';

import '../models/glossar.dart';
import '../redux/actions.dart' as actions;
import '../redux/state.dart';
import '../redux/store.dart';
import '../storage/database.dart';

class GlossarListPage extends StatefulWidget {
  const GlossarListPage({super.key});

  @override
  State<GlossarListPage> createState() => _GlossarListPageState();
}

class _GlossarListPageState extends State<GlossarListPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  String _title = '';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();

    if (Platform.isAndroid) {
      getImportData().then((glossar) async {
        if (glossar != null) {
          final Glossar? newGlossar = await showDialog(
              context: context,
              builder: (context) {
                return ImportExternDialog(glossar: glossar);
              });

          if (newGlossar != null) {
            store.dispatch(
              actions.Action(
                actions.ActionTypes.addGlossary,
                payload: newGlossar,
              ),
            );

            saveGlossarys();
            saveGlossaryEntrys();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddGlossarDialog(bool isSynced) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!
              .addGlossary(isSynced ? 'shared' : 'local')),
          content: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onSaved: (value) {
                    _title = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty ||
                        store.state.glossars
                            .any((glossar) => glossar.title == value)) {
                      return AppLocalizations.of(context)!.enterValidName;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.submit),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  String? id;

                  if (isSynced) id = await createSyncGlossary(_title);

                  store.dispatch(
                    actions.Action(
                      actions.ActionTypes.addGlossary,
                      payload: Glossar(
                        id: id,
                        title: _title,
                        isSynced: isSynced,
                      ),
                    ),
                  );

                  Navigator.of(context).pop();

                  saveGlossarys();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<AppState, AppState>(
          converter: (state) => store.state,
          builder: (context, state) {
            // return a list of all glossarys, when tapping on a glossar navigate to the glossar page
            return RefreshIndicator(
                onRefresh: () {
                  return updateSyncGlossarys();
                },
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 45.0),
                    child: Text(
                      AppLocalizations.of(context)!.glossaryList,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.glossars.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                              title: Text(state.glossars[index].title),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enableFeedback: true,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/glossar',
                                  arguments: state.glossars[index],
                                );
                                setState(() {});
                              },
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                          AppLocalizations.of(context)!.delete),
                                      content: Text(
                                          (state.glossars[index].isSynced)
                                              ? AppLocalizations.of(context)!
                                                  .leaveGlossaryQuestion
                                              : AppLocalizations.of(context)!
                                                  .deleteGlossaryQuestion),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .cancel),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            (state.glossars[index].isSynced)
                                                ? AppLocalizations.of(context)!
                                                    .leave
                                                : AppLocalizations.of(context)!
                                                    .delete,
                                          ),
                                          onPressed: () {
                                            if (state
                                                .glossars[index].isSynced) {
                                              leaveSyncedGlossary(
                                                  state.glossars[index].id!);
                                            } else {
                                              removeGlossary(
                                                  state.glossars[index]);
                                            }
                                            store.dispatch(
                                              actions.Action(
                                                actions
                                                    .ActionTypes.removeGlossary,
                                                payload: state.glossars[index],
                                              ),
                                            );
                                            Navigator.of(context).pop();
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                        );
                      },
                    ),
                  ),
                ]));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // show pop up menu to chose between adding a glossar manually or importing a glossar
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.add),
                    title:
                        Text(AppLocalizations.of(context)!.createLocalGlossary),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAddGlossarDialog(false);
                    },
                  ),
                  ListTile(
                      leading: const Icon(Icons.sync),
                      title: Text(
                          AppLocalizations.of(context)!.createSharedGlossary),
                      onTap: () {
                        Navigator.of(context).pop();
                        _showAddGlossarDialog(true);
                      }),
                  ListTile(
                    leading: const Icon(Icons.file_upload),
                    title: Text(AppLocalizations.of(context)!.import),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final Glossar? glossar = await showDialog(
                          context: context,
                          builder: (context) {
                            return const ImportDialog();
                          });

                      if (glossar != null) {
                        store.dispatch(
                          actions.Action(
                            actions.ActionTypes.addGlossary,
                            payload: glossar,
                          ),
                        );

                        saveGlossarys();
                        saveGlossaryEntrys();
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.group_add),
                    title:
                        Text(AppLocalizations.of(context)!.joinSharedGlossary),
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (context) {
                            bool idExists = false;
                            final controller = TextEditingController();
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!
                                  .joinSharedGlossary),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .joinCode),
                                      onSaved: (value) {
                                        _title = value!;
                                      },
                                      onChanged: (value) async {
                                        final doc = await FirebaseFirestore
                                            .instance
                                            .collection('glossarys')
                                            .doc(value)
                                            .get();
                                        if (doc.exists) {
                                          setState(() {
                                            idExists = true;
                                          });
                                        } else {
                                          setState(() {
                                            idExists = false;
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .enterJoinCode;
                                        }
                                        if (!idExists) {
                                          return AppLocalizations.of(context)!
                                              .invalidJoinCode;
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text(
                                      AppLocalizations.of(context)!.submit),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();

                                      Navigator.of(context).pop();

                                      addSync(controller.text);

                                      loadSyncGlossary(controller.text)
                                          .then((glossar) {
                                        if (glossar != null) {
                                          store.dispatch(
                                            actions.Action(
                                              actions.ActionTypes.addGlossary,
                                              payload: glossar,
                                            ),
                                          );
                                        }
                                      });
                                    }
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
