class Task {
  String id;
  String title;
  String column;
  String? completionDate;

  Task(
      {required this.id,
      required this.title,
      required this.column,
      this.completionDate});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'column': column,
      'completionDate': completionDate
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
        id: json['id'],
        title: json['title'],
        column: json['column'],
        completionDate: json['completionDate'] as String?);
  }
}
