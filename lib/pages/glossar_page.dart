import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:glossarium/main.dart';
import 'package:glossarium/models/glossar.dart';
import 'package:glossarium/storage/database.dart';
import 'package:glossarium/storage/firestore.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' hide context;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/glossar_entry.dart';
import '../redux/actions.dart' as actions;
import '../redux/store.dart';

class GlossarPage extends StatefulWidget {
  const GlossarPage({super.key});

  @override
  State<GlossarPage> createState() => _GlossarPageState();
}

class _GlossarPageState extends State<GlossarPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listener;
  Glossar? _glossar;
  String _title = '';
  String _description = '';
  List<GlossarEntry> _filteredGlossarEntrys = [];
  final List<GlossarEntry> _selectedGlossarEntrys = [];
  Glossar? _selectedGlossar;

  // Define sorting options
  final List<String> _sortOptions = [
    AppLocalizations.of(rootBuildContext!)!.sortOptionAuthorIncreasing,
    AppLocalizations.of(rootBuildContext!)!.sortOptionAuthorDecreasing
  ];
  String _currentSortOption = 'Titel (A-Z)';

  // Define a variable to hold the current selected sorting option
  int Function(GlossarEntry, GlossarEntry) _currentSortFunction =
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase());

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    Future.delayed(Duration.zero, () {
      setState(() {
        _glossar = ModalRoute.of(context)!.settings.arguments as Glossar;
        log('Glossar ID: ${_glossar?.id}');
        _listener = (_glossar!.isSynced)
            ? FirebaseFirestore.instance
                .collection('glossarys')
                .doc(_glossar?.id)
                .collection('entrys')
                .snapshots()
                .listen((event) {
                log('Glossar changed: ${event.docChanges.length}');
                for (var change in event.docChanges) {
                  switch (change.type) {
                    case DocumentChangeType.added:
                      log('Item added: ${change.doc.id}');

                      if (_glossar!.entries
                          .any((entry) => entry.title == change.doc.id)) {
                        log('Item already exists');
                        store.dispatch(actions.Action(
                          actions.ActionTypes.updateGlossaryItem,
                          payload: GlossarEntry(
                            title: change.doc.id,
                            description:
                                change.doc.data()?['description'] ?? '',
                            creator: change.doc.data()?['creator'],
                          ).toMap(),
                        ));
                        setState(() {
                          _glossar = _glossar?.copyWith(
                              entries: _glossar!.entries.map((entry) {
                            if (entry.title == change.doc.id) {
                              return GlossarEntry(
                                title: change.doc.id,
                                description:
                                    change.doc.data()?['description'] ?? '',
                                creator: change.doc.data()?['creator'],
                              );
                            }
                            return entry;
                          }).toList());
                        });
                        _filterGlossarEntrys();
                        break;
                      }

                      store.dispatch(actions.Action(
                        actions.ActionTypes.addGlossaryItem,
                        payload: GlossarEntry(
                          title: change.doc.id,
                          description: change.doc.data()?['description'] ?? '',
                          creator: change.doc.data()?['creator'],
                        ).toMap(),
                      ));
                      setState(() {
                        _glossar = _glossar?.copyWith(entries: [
                          ..._glossar!.entries,
                          GlossarEntry(
                            title: change.doc.id,
                            description:
                                change.doc.data()?['description'] ?? '',
                            creator: change.doc.data()?['creator'],
                          )
                        ]);
                      });
                      _filterGlossarEntrys();
                      break;
                    case DocumentChangeType.modified:
                      log('Item modified: ${change.doc.id}');
                      store.dispatch(actions.Action(
                        actions.ActionTypes.updateGlossaryItem,
                        payload: GlossarEntry(
                          title: change.doc.id,
                          description: change.doc.data()?['description'] ?? '',
                          creator: change.doc.data()?['creator'],
                        ).toMap(),
                      ));
                      setState(() {
                        _glossar = _glossar?.copyWith(
                            entries: _glossar!.entries.map((entry) {
                          if (entry.title == change.doc.id) {
                            return GlossarEntry(
                              title: change.doc.id,
                              description:
                                  change.doc.data()?['description'] ?? '',
                              creator: change.doc.data()?['creator'],
                            );
                          }
                          return entry;
                        }).toList());
                      });
                      _filterGlossarEntrys();
                      break;
                    case DocumentChangeType.removed:
                      log('Item removed: ${change.doc.id}');
                      store.dispatch(actions.Action(
                        actions.ActionTypes.removeGlossaryItem,
                        payload: {
                          'title': change.doc.id,
                          'glossary': _glossar!.title,
                        },
                      ));
                      setState(() {
                        _glossar = _glossar?.copyWith(
                            entries: _glossar!.entries
                                .where((entry) => entry.title != change.doc.id)
                                .toList());
                      });
                      _filterGlossarEntrys();
                      break;
                  }
                }
              })
            : null;
        if (_glossar!.isSynced) {
          _sortOptions
              .add(AppLocalizations.of(context)!.sortOptionAuthorIncreasing);
          _sortOptions
              .add(AppLocalizations.of(context)!.sortOptionAuthorDecreasing);
        }
      });
      _filterGlossarEntrys();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _listener?.cancel();
    super.dispose();
  }

  Future<void> _showAddGlossarEntryDialog(GlossarEntry? oldEntry) async {
    final GlossarEntry? newEntry = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addEntry),
          content: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Begriff'),
                  enabled: oldEntry == null,
                  initialValue: oldEntry?.title,
                  onSaved: (value) {
                    _title = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Bitte gib einen Begriff ein';
                    }
                    if (oldEntry == null &&
                        _glossar!.entries
                            .any((entry) => entry.title == value)) {
                      return 'Dieser Begriff existiert bereits';
                    }
                    if (value.contains('[\\;]')) {
                      return 'Der Begriff darf kein Semikolon oder Backslash enthalten';
                    }
                    if (value.contains('\n')) {
                      return 'Der Begriff darf kein Zeilenumbruch enthalten';
                    }
                    if (value.length > 50) {
                      return 'Der Begriff darf maximal 50 Zeichen lang sein';
                    }
                    return null;
                  },
                ),
                Expanded(
                  child: TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Beschreibung'),
                    initialValue: oldEntry?.description,
                    maxLines: null,
                    onSaved: (value) {
                      _description = value!;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Bitte gib eine Beschreibung ein';
                      }
                      if (value.contains('\n')) {
                        return 'Die Beschreibung darf keinen Zeilenumbruch enthalten';
                      }
                      if (value.contains(';')) {
                        return 'Die Beschreibung darf kein Semikolon enthalten';
                      }
                      if (value.length > 500) {
                        return 'Die Beschreibung darf maximal 500 Zeichen lang sein';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.submit),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  final entry = GlossarEntry(
                    title: _title,
                    description: _description,
                  );

                  Navigator.of(context).pop(entry);
                }
              },
            ),
          ],
        );
      },
    );
    if (newEntry == null) {
      return;
    }
    if (oldEntry != null) {
      if (oldEntry.equals(newEntry)) {
        return;
      }
      final entryMap = newEntry.toMap();
      entryMap['glossary'] = _glossar!.title;
      store.dispatch(actions.Action(
        actions.ActionTypes.updateGlossaryItem,
        payload: entryMap,
      ));
      if (_glossar!.isSynced) updateSyncGlossaryEntry(_glossar!.id!, newEntry);
      setState(() {
        _glossar = _glossar?.copyWith(
            entries: _glossar!.entries.map((entry) {
          if (entry.title == oldEntry.title) {
            return newEntry;
          }
          return entry;
        }).toList());
      });
    } else {
      final entryMap = newEntry.toMap();
      entryMap['glossary'] = _glossar!.title;
      store.dispatch(actions.Action(
        actions.ActionTypes.addGlossaryItem,
        payload: entryMap,
      ));
      if (_glossar!.isSynced) {
        addSyncGlossaryEntry(_glossar!.id!, newEntry);
      } else {
        setState(() {
          _glossar =
              _glossar?.copyWith(entries: [..._glossar!.entries, newEntry]);
        });
      }
    }
    await saveGlossaryEntrys();
    _filterGlossarEntrys();
  }

  void _filterGlossarEntrys() {
    setState(() {
      _filteredGlossarEntrys = (_glossar?.entries ?? [])
          .where((entry) =>
              entry.title
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              entry.description
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
      _filteredGlossarEntrys.sort(_currentSortFunction);
    });
  }

  Future<void> _exportAsPdf() async {
    final pdf = pw.Document();
    final regular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final bold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    _glossar?.entries
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Center(
                    child: pw.Text(_glossar!.title,
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 30,
                            fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center)),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text('${_glossar!.entries.length} Einträge',
                      style: pw.TextStyle(
                          font: regular,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.normal)),
                )
              ],
            ),
          );
        },
      ),
    );
    pdf.addPage(pw.MultiPage(
        build: (pw.Context context) => _glossar!.entries
            .map((entry) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(entry.title,
                        style: pw.TextStyle(
                            font: bold, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text(entry.description,
                        style: pw.TextStyle(
                            font: regular, fontWeight: pw.FontWeight.normal)),
                    pw.SizedBox(height: 20),
                  ],
                ))
            .toList()));
    var file = File(
        '/storage/emulated/0/Download/${_glossar?.title ?? 'glossary'}.pdf');
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      file = File(
          '/storage/emulated/0/Download/${_glossar?.title ?? 'glossary'}-${DateTime.now().millisecondsSinceEpoch}.pdf');
    }
    try {
      await file.writeAsBytes(await pdf.save());
    } on FileSystemException {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Glossar konnte nicht als PDF exportiert werden'),
        ),
      );
      return;
    }
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Text('Glossar wurde als PDF exportiert'),
        action: SnackBarAction(
          label: 'Öffnen',
          onPressed: () {
            // open the pdf file
            OpenFilex.open(file.path, type: 'application/pdf');
          },
        ),
      ),
    );
  }

  List<TextSpan> _highlightOccurrences(String source, String query,
      String? creator, TextStyle style, TextStyle highlightStyle) {
    if (query.isEmpty) {
      return [
        TextSpan(text: source, style: style),
        (creator != null)
            ? TextSpan(
                text: ' ($creator)', style: const TextStyle(color: Colors.blue))
            : const TextSpan()
      ];
    }
    final splitMap = source.toLowerCase().split(query);
    final List<TextSpan> spans = [];
    var currentIndex = 0;
    for (var element in splitMap) {
      spans.add(TextSpan(
          text: source.substring(currentIndex, currentIndex + element.length),
          style: style));
      currentIndex += element.length;
      if (currentIndex < source.length) {
        spans.add(TextSpan(
            text: source.substring(currentIndex, currentIndex + query.length),
            style: highlightStyle));
        currentIndex += query.length;
      }
    }
    if (creator != null)
      spans.add(TextSpan(
          text: ' ($creator)', style: const TextStyle(color: Colors.blue)));
    return spans;
  }

  Future<void> _exportAsCSV() async {
    final path = join((await getApplicationCacheDirectory()).path,
        '${_glossar?.title ?? 'glossary'}.csv');
    final file = File(path);
    final csv =
        'Begriff;Beschreibung\n${_glossar?.entries.map((entry) => '${entry.title};${entry.description}').join('\n') ?? ''}';
    await file.writeAsString(csv, mode: FileMode.writeOnly, flush: true);
    Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')],
        text: 'Glossar exportiert');
  }

  Future<void> _exportSynced() async {
    Share.share(
        'Tritt dem Glossar ${_glossar?.title} mit dem Code: ${_glossar?.id} bei.');
  }

  Future<void> _removeEntries() async {
    for (var entry in _selectedGlossarEntrys) {
      if (_glossar!.isSynced) {
        removeSyncGlossaryEntry(_glossar!.id!, entry);
      } else {
        removeGlossaryEntry(entry);
      }
    }
    setState(() {
      _glossar = _glossar?.copyWith(
          entries: _glossar!.entries
              .where((entry) => !_selectedGlossarEntrys.contains(entry))
              .toList());
    });
    _selectedGlossarEntrys.clear();
    _filterGlossarEntrys();
  }

  Future<void> _exportEntries() async {
    final Glossar? glossar = await _selectGlossar();

    if (glossar == null) {
      return;
    }

    for (var entry in _selectedGlossarEntrys) {
      if (glossar.entries.any((element) => element.title == entry.title)) {
        continue;
      }
      _addEntryToGlossar(glossar, entry);
    }
    await saveGlossaryEntrys();
    _filterGlossarEntrys();
  }

  Future<Glossar?> _selectGlossar() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.selectGlossary),
            content: _buildGlossarDropdown(),
            actions: _buildDialogActions(),
          );
        });
  }

  DropdownButtonFormField<Glossar> _buildGlossarDropdown() {
    return DropdownButtonFormField<Glossar>(
      style: const TextStyle(color: Colors.deepPurple),
      items: _buildGlossarItems(),
      onChanged: (Glossar? newValue) {
        setState(() {
          _selectedGlossar = newValue;
        });
      },
    );
  }

  List<DropdownMenuItem<Glossar>> _buildGlossarItems() {
    return store.state.glossars
        .where((glossar) => glossar.title != _glossar?.title)
        .map<DropdownMenuItem<Glossar>>((Glossar value) {
      return DropdownMenuItem<Glossar>(
        value: value,
        child: Text(
          value.title,
          textAlign: TextAlign.center,
        ),
      );
    }).toList();
  }

  List<Widget> _buildDialogActions() {
    return [
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(AppLocalizations.of(context)!.cancel),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop(_selectedGlossar);
        },
        child: Text(AppLocalizations.of(context)!.submit),
      ),
    ];
  }

  void _addEntryToGlossar(Glossar glossar, GlossarEntry entry) {
    final entryMap = entry.toMap();
    entryMap['glossary'] = glossar.title;
    store.dispatch(actions.Action(
      actions.ActionTypes.addGlossaryItem,
      payload: entryMap,
    ));
    if (glossar.isSynced) addSyncGlossaryEntry(glossar.id!, entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_glossar?.title ?? 'Glossar'),
        actions: [
          if (_selectedGlossarEntrys.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.check_box),
                onPressed: () {
                  if (_selectedGlossarEntrys.length ==
                      _filteredGlossarEntrys.length) {
                    setState(() {
                      _selectedGlossarEntrys.clear();
                    });
                  } else {
                    setState(() {
                      _selectedGlossarEntrys.clear();
                      _selectedGlossarEntrys.addAll(_filteredGlossarEntrys);
                    });
                  }
                }),
          (_selectedGlossarEntrys.isEmpty)
              ? IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: _exportAsPdf,
                )
              : IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: _removeEntries,
                ),
          (_selectedGlossarEntrys.isEmpty)
              ? IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: (_glossar?.isSynced ?? false)
                      ? _exportSynced
                      : _exportAsCSV,
                )
              : IconButton(
                  icon: const Icon(Icons.import_export),
                  onPressed: _exportEntries,
                ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Suche',
                hintText: 'Suche',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filterGlossarEntrys();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Sortieren: '),
                DropdownButton<String>(
                  value: _currentSortOption,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _currentSortOption = newValue!;
                      // Sort the _filteredGlossarEntrys list based on the selected option
                      if (_currentSortOption ==
                          AppLocalizations.of(context)!
                              .sortOptionTitleIncreasing) {
                        _currentSortFunction = (a, b) => a.title
                            .toLowerCase()
                            .compareTo(b.title.toLowerCase());
                      } else if (_currentSortOption ==
                          AppLocalizations.of(context)!
                              .sortOptionTitleDecreasing) {
                        _currentSortFunction = (a, b) => b.title
                            .toLowerCase()
                            .compareTo(a.title.toLowerCase());
                      } else if (_currentSortOption ==
                          AppLocalizations.of(context)!
                              .sortOptionAuthorIncreasing) {
                        _currentSortFunction = (a, b) => a.creator!
                            .toLowerCase()
                            .compareTo(b.creator!.toLowerCase());
                      } else if (_currentSortOption ==
                          AppLocalizations.of(context)!
                              .sortOptionAuthorDecreasing) {
                        _currentSortFunction = (a, b) => b.creator!
                            .toLowerCase()
                            .compareTo(a.creator!.toLowerCase());
                      }
                      _filteredGlossarEntrys.sort(_currentSortFunction);
                    });
                  },
                  items: _sortOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredGlossarEntrys.length + 1,
              itemBuilder: (context, index) {
                if (index == _filteredGlossarEntrys.length) {
                  return const SizedBox(height: 80);
                }
                final String title = _filteredGlossarEntrys[index].title;
                final String description =
                    _filteredGlossarEntrys[index].description;
                final String searchText = _searchController.text.toLowerCase();
                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      children: _highlightOccurrences(
                          title,
                          searchText,
                          _filteredGlossarEntrys[index].creator,
                          const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      children: _highlightOccurrences(
                          description,
                          searchText,
                          null,
                          const TextStyle(color: Colors.black),
                          const TextStyle(color: Colors.red)),
                    ),
                  ),
                  onTap: () {
                    _showAddGlossarEntryDialog(_filteredGlossarEntrys[index]);
                  },
                  onLongPress: () async {
                    setState(() {
                      if (_selectedGlossarEntrys
                          .contains(_filteredGlossarEntrys[index])) {
                        _selectedGlossarEntrys
                            .remove(_filteredGlossarEntrys[index]);
                      } else {
                        _selectedGlossarEntrys
                            .add(_filteredGlossarEntrys[index]);
                      }
                    });
                  },
                  selected: _selectedGlossarEntrys
                      .contains(_filteredGlossarEntrys[index]),
                  selectedTileColor: Colors.grey[300],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGlossarEntryDialog(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
