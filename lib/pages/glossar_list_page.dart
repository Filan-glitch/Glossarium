import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:glossarium/dialogs/import_dialog.dart';
import 'package:glossarium/dialogs/import_extern_dialog.dart';
import 'package:glossarium/services/import.dart';
import 'package:glossarium/storage/firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/glossar.dart';
import '../redux/state.dart';
import '../redux/store.dart';
import '../storage/database.dart';
import '../redux/actions.dart' as actions;

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
              }
          );

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
          title: Text(''),
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
                    if (value!.isEmpty || store.state.glossars.any((glossar) => glossar.title == value)) {
                      return 'Bitte gib einen gültigen Namen ein';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Bestätigen'),
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
                child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 45.0),
                        child: Text('Glossar Liste', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
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
                                          title: const Text('Löschen'),
                                          content: Text((state.glossars[index].isSynced) ? 'Möchtest du aus dem synchronisierten Glossar austreten?' : 'Möchtest du das Glossar und alle Einträge wirklich löschen?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Abbrechen'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text((state.glossars[index].isSynced) ? 'Austreten' : 'Löschen'),
                                              onPressed: () {
                                                if (state.glossars[index].isSynced) {
                                                  leaveSyncedGlossary(state.glossars[index].id!);
                                                } else {
                                                  removeGlossary(state.glossars[index]);
                                                }
                                                store.dispatch(
                                                  actions.Action(
                                                    actions.ActionTypes.removeGlossary,
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
                                  }
                              ),
                            );
                          },
                        ),
                      ),
                    ]
                )
            );
          }
      ),
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
                    title: const Text('Lokales Glossar erstellen'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAddGlossarDialog(false);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Synchrones Glossar erstellen'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAddGlossarDialog(true);
                    }
                  ),
                  ListTile(
                    leading: const Icon(Icons.file_upload),
                    title: const Text('Importieren'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final Glossar? glossar = await showDialog(
                        context: context,
                        builder: (context) {
                          return const ImportDialog();
                        }
                      );

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
                    title: const Text('Synchronem Glossar beitreten'),
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) {
                          bool idExists = false;
                          final controller = TextEditingController();
                          return AlertDialog(
                            title: const Text('Synchronem Glossar beitreten'),
                            content: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    controller: controller,
                                    decoration: const InputDecoration(labelText: 'ID'),
                                    onSaved: (value) {
                                      _title = value!;
                                    },
                                    onChanged: (value) async {
                                      final doc = await FirebaseFirestore.instance.collection('glossarys').doc(value).get();
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
                                        return 'Bitte gib eine ID ein';
                                      }
                                      if (!idExists) {
                                        return 'Diese ID existiert nicht';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Bestätigen'),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();

                                    Navigator.of(context).pop();

                                    addSync(controller.text);

                                    loadSyncGlossary(controller.text).then((glossar) {
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
                        }
                      );
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
