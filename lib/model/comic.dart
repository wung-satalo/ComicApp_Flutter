import 'chapters.dart';

class Comic {
  String category;
  String name;
  String image;
  List<Chapters> chapters;

  Comic({
    this.category = '',
    this.name = '',
    this.image = '',
    List<Chapters>? chapters,
  }) : chapters = chapters ?? [];

  Comic.fromJson(Map<String, dynamic> json)
      : category = json['category'] ?? '',
        image = json['Image'] ?? '',
        name = json['Name'] ?? '', 
        chapters = json['Chapters'] != null
            ? (json['Chapters'] as List)
                .map((v) => Chapters.fromJson(v))
                .toList()
            : [];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Category'] = category;
    data['Chapters'] = chapters.map((v) => v.toJson()).toList();
    data['Image'] = image;
    data['Name'] = name;
    return data;
  }
}