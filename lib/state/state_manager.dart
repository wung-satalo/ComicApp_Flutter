
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comico/model/chapters.dart';
import 'package:comico/model/comic.dart';

final comicSelected = StateProvider((ref) => Comic());
final chapterSelected = StateProvider((ref) => Chapters());
final isSearch = StateProvider((ref) => false);

final readingModeProvider = StateProvider<ReadingMode>(
  (ref) => ReadingMode.horizontal,
);

enum ReadingMode { horizontal, vertical }