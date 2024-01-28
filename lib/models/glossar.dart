import 'glossar_entry.dart';

class Glossar {
  final String? id;
  final String title;
  final List<GlossarEntry> entries;
  final bool isSynced;

  const Glossar({required this.title, this.entries = const [], this.isSynced = false, this.id});

  Map<String, dynamic> toMap() {
    return {
      'title': title
    };
  }

 static Glossar fromMap(Map<String, dynamic> map) {
    return Glossar(
      id: map['id'],
      title: map['title'],
      entries: map['entries'] ?? const [],
      isSynced: map['isSynced'] ?? false,
    );
  }

  Glossar copyWith({
    String? id,
    String? title,
    List<GlossarEntry>? entries,
    bool? isSynced,
  }) {
    return Glossar(
      id: id ?? this.id,
      title: title ?? this.title,
      entries: entries ?? this.entries,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}