import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glossarium/storage/database.dart';

import '../models/glossar.dart';
import '../models/glossar_entry.dart';
import '../redux/store.dart';
import '../redux/actions.dart';

Future<void> loadSyncGlossarys() async {
  final db = FirebaseFirestore.instance;
  final syncs = await loadSyncs();
  final syncIDs = syncs.map((map) {
      return map['id'] as String;
    }
  ).toList();

  for(var id in syncIDs) {
    final glossary = await db.collection('glossarys').doc(id).get();

    if(!glossary.exists) continue;
    if(glossary.data()!['title'] == null) continue;

    store.dispatch(
        Action(
            ActionTypes.addGlossary,
            payload: Glossar(
              id: id,
              title: glossary.get('title') as String,
              isSynced: true,
            )
        )
    );
  }
}

Future<void> updateSyncGlossarys() async {
  final db = FirebaseFirestore.instance;
  final syncs = await loadSyncs();
  final syncIDs = syncs.map((map) {
      return map['id'] as String;
    }
  ).toList();

  for(var id in syncIDs) {
    final glossary = await db.collection('glossarys').doc(id).get();

    store.dispatch(
        Action(
            ActionTypes.updateGlossary,
            payload: Glossar(
              id: id,
              title: glossary.get('title') as String,
              isSynced: true,
            )
        )
    );
  }
}

Future<Glossar?> loadSyncGlossary(String id) async {
  final db = FirebaseFirestore.instance;
  final glossary = await db.collection('glossarys').doc(id).get();

  return Glossar(
    id: id,
    title: glossary.get('title') as String,
    isSynced: true,
  );
}

Future<String> createSyncGlossary(String glossaryTitle) async {
  final db = FirebaseFirestore.instance;
  final doc = await db.collection('glossarys').add({'title': glossaryTitle});
  addSync(doc.id);
  return doc.id;
}

Future<void> addSyncGlossaryEntry(String glossaryID, GlossarEntry entry) async {
  final db = FirebaseFirestore.instance;
  await db.collection('glossarys').doc(glossaryID).collection('entrys').doc(entry.title).set({'description': entry.description, 'creator': FirebaseAuth.instance.currentUser?.displayName});
}

Future<void> updateSyncGlossaryEntry(String glossaryID, GlossarEntry entry) async {
  final db = FirebaseFirestore.instance;
  await db.collection('glossarys').doc(glossaryID).collection('entrys').doc(entry.title).set({'description': entry.description, 'creator': FirebaseAuth.instance.currentUser?.displayName});
}

Future<void> removeSyncGlossaryEntry(String glossaryID, GlossarEntry entry) async {
  final db = FirebaseFirestore.instance;
  await db.collection('glossarys').doc(glossaryID).collection('entrys').doc(entry.title).delete();
}