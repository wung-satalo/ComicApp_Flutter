import 'chapters.dart';

class Comic {
  int id;
  String category;
  String name;
  String image;
  List<Chapters> chapters;

  Comic({
    this.id = 0,
    this.category = '',
    this.name = '',
    this.image = '',
    List<Chapters>? chapters,
  }) : chapters = chapters ?? [];

  Comic.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        category = json['category'] ?? '',
        image = json['image'] ?? '',
        name = json['name'] ?? '',
        chapters = json['chapters'] != null
            ? (json['chapters'] as List)
                .map((v) => Chapters.fromJson(v))
                .toList()
            : [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'chapters': chapters.map((v) => v.toJson()).toList(),
      'image': image,
      'name': name,
    };
  }
}