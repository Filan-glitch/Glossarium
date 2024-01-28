class GlossarEntry {
  final String title;
  final String description;
  final String? creator;

  const GlossarEntry({required this.title, required this.description, this.creator});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'creator': creator,
    };
  }

  static GlossarEntry fromMap(Map<String, dynamic> map) {
    return GlossarEntry(
      title: map['title'],
      description: map['description'],
      creator: map['creator'],
    );
  }

  GlossarEntry copyWith({
    String? title,
    String? description,
    String? creator,
  }) {
    return GlossarEntry(
      title: title ?? this.title,
      description: description ?? this.description,
      creator: creator ?? this.creator,
    );
  }
}