import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/glossar.dart';
import '../models/glossar_entry.dart';
import '../redux/actions.dart';
import '../redux/store.dart';

// loads the glossarys from the sqflite database
Future<void> loadGlossarys() async {
  final Database db = await openDatabase(
    join(await getDatabasesPath(), 'glossarys.db'),
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE entrys('
            'title TEXT PRIMARY KEY, '
            'description TEXT, '
            'glossary TEXT,'
            'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
            ')'
      );
      await db.execute('CREATE TABLE glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
    },
    onOpen: (db) async {
      await db.execute(
        'CREATE TABLE IF NOT EXISTS entrys('
            'title TEXT PRIMARY KEY, '
            'description TEXT, '
            'glossary TEXT,'
            'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
            ')'
      );
      await db.execute('CREATE TABLE IF NOT EXISTS glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE IF NOT EXISTS syncs(id TEXT PRIMARY KEY)');
    },
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    version: 1,
  );
  final List<Map<String, dynamic>> maps = await db.query('glossarys');

  // Convert the List<Map<String, dynamic> into a List<Glossary>.
  var glossarys =  List.generate(maps.length, (i) {
    return Glossar(
      title: maps[i]['title']
    );
  });

  // add the glossarys to the store
  store.dispatch(Action(ActionTypes.loadGlossarys, payload: glossarys));
}

// loads the glossary entrys from the sqflite database
Future<void> loadGlossaryEntrys() async {
  final Database db = await openDatabase(
    join(await getDatabasesPath(), 'glossarys.db'),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
    },
    onOpen: (db) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE IF NOT EXISTS glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE IF NOT EXISTS syncs(id TEXT PRIMARY KEY)');
    },
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    version: 1,
  );
  final List<Map<String, dynamic>> maps = await db.query('entrys');

  var entrys =  List.generate(maps.length, (i) {
    var entry = GlossarEntry(
      title: maps[i]['title'],
      description: maps[i]['description']
    ).toMap();
    entry['glossary'] = maps[i]['glossary'];
    entry.remove('creator');
    return entry;
  });


  // add the glossarys to the store
  store.dispatch(Action(ActionTypes.loadGlossaryEntrys, payload: entrys));
}

Future<List<Map<String, Object?>>> loadSyncs() async {
  final Database db = await openDatabase(
    join(await getDatabasesPath(), 'glossarys.db'),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
    },
    onOpen: (db) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE IF NOT EXISTS glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE IF NOT EXISTS syncs(id TEXT PRIMARY KEY)');
    },
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    version: 1,
  );

  return await db.query('syncs');
}

// adds a glossary to the sqflite database
Future<void> saveGlossarys() async {
  final Database db = await openDatabase(
    join(await getDatabasesPath(), 'glossarys.db'),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
    },
    onOpen: (db) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE IF NOT EXISTS glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE IF NOT EXISTS syncs(id TEXT PRIMARY KEY)');
    },
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    version: 1,
  );

  var unsyncedGlossars = store.state.glossars.where((glossar) => !glossar.isSynced);

  await db.transaction((txn) async {
    for (var glossar in unsyncedGlossars) {
      await txn.insert('glossarys', glossar.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  });

}

// adds all glossary entrys to the sqflite database
Future<void> saveGlossaryEntrys() async {
final Database db = await openDatabase(
    join(await getDatabasesPath(), 'glossarys.db'),
  onCreate: (db, version) async {
    await db.execute(
        'CREATE TABLE entrys('
            'title TEXT PRIMARY KEY, '
            'description TEXT, '
            'glossary TEXT,'
            'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
            ')'
    );
    await db.execute('CREATE TABLE glossarys(title TEXT PRIMARY KEY)');
    await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
  },
  onOpen: (db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS entrys('
            'title TEXT PRIMARY KEY, '
            'description TEXT, '
            'glossary TEXT,'
            'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
            ')'
    );
    await db.execute('CREATE TABLE IF NOT EXISTS glossarys(title TEXT PRIMARY KEY)');
    await db.execute('CREATE TABLE IF NOT EXISTS syncs(id TEXT PRIMARY KEY)');
  },
  onConfigure: (db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  },
    version: 1,
  );

  var unsyncedGlossars = store.state.glossars.where((glossar) => !glossar.isSynced);

  await db.transaction((txn) async {
    for (var glossar in unsyncedGlossars) {
      for (var entry in glossar.entries) {
        var entryMap = entry.toMap();
        entryMap['glossary'] = glossar.title;
        entryMap.remove('creator');
        await txn.insert('entrys', entryMap, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  });
}

Future<void> addSync(String id) async {
  final Database db = await openDatabase(
    join(await getDatabasesPath(), 'glossarys.db'),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
    },
    onOpen: (db) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE IF NOT EXISTS glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE IF NOT EXISTS syncs(id TEXT PRIMARY KEY)');
    },
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    version: 1,
  );

  await db.insert(
    'syncs',
    {
      'id': id
    }
  );
}

Future<void> removeGlossaryEntry(GlossarEntry entry) async {
  final Database db = await openDatabase(
    join(await getDatabasesPath(), 'glossarys.db'),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
    },
    onOpen: (db) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE IF NOT EXISTS glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
    },
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    version: 1,
  );

  await db.delete(
    'entrys',
    where: 'title = ?',
    whereArgs: [entry.title],
  );
}

Future<void> removeGlossary(Glossar glossar) async {
  final Database db = await openDatabase(
    join(await getDatabasesPath(), 'glossarys.db'),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
    },
    onOpen: (db) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title) ON DELETE CASCADE'
              ')'
      );
      await db.execute('CREATE TABLE IF NOT EXISTS glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE IF NOT EXISTS syncs(id TEXT PRIMARY KEY)');
    },
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    version: 1,
  );

  await db.delete(
    'glossarys',
    where: 'title = ?',
    whereArgs: [glossar.title],
  );


}

Future<void> leaveSyncedGlossary(String id) async {
  final Database db = await openDatabase(
    join(await getDatabasesPath(), 'glossarys.db'),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title)'
              ')'
      );
      await db.execute('CREATE TABLE glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE syncs(id TEXT PRIMARY KEY)');
    },
    onOpen: (db) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS entrys('
              'title TEXT PRIMARY KEY, '
              'description TEXT, '
              'glossary TEXT,'
              'FOREIGN KEY(glossary) REFERENCES glossarys(title)'
              ')'
      );
      await db.execute('CREATE TABLE IF NOT EXISTS glossarys(title TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE IF NOT EXISTS syncs(id TEXT PRIMARY KEY)');
    },
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    version: 1,
  );

  await db.delete(
    'syncs',
    where: 'id = ?',
    whereArgs: [id]
  );
}