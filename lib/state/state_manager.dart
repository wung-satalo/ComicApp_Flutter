
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_app/model/chapters.dart';
import 'package:reader_app/model/comic.dart';

final comicSelected = StateProvider((ref) => Comic());
final chapterSelected = StateProvider((ref) => Chapters());
final isSearch = StateProvider((ref) => false);