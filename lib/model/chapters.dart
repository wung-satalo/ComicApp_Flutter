class Chapters {
  int id;
  String name;
  List<String> links;

  Chapters({
    this.id = 0,
    this.name = '',
    List<String>? links,
  }) : links = links ?? [];

  Chapters.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        name = json['name'] ?? '',
        links = json['links'] != null
            ? List<String>.from(json['links'])
            : [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'links': links,
    };
  }
}