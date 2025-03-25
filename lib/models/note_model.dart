
class Note {
  int? id;
  String title;
  String? content;
  String? color;
  DateTime dateCreated;
  DateTime dateUpdated;
  DateTime? dateDeleted;
  bool isDeleted;

  Note({
    this.id,
    required this.title,
    this.content,
    this.color,
    required this.dateCreated,
    required this.dateUpdated,
    this.dateDeleted,
    this.isDeleted = false,
  });

  // Convert a Map to a Note object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      color: map['color'],
      dateCreated: DateTime.parse(map['date_created']),
      dateUpdated: DateTime.parse(map['date_updated']),
      dateDeleted: map['date_deleted'] != null ? DateTime.parse(map['date_deleted']) : null, // placeholder to avoid null error
      isDeleted: map['is_deleted'] == 1,
    );
  }

  // Convert a Note object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'date_created': dateCreated.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'date_deleted': dateDeleted?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

}
