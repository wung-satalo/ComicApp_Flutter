import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_app/state/state_manager.dart';

class ReadScreen extends ConsumerWidget {
  const ReadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comic = ref.watch(comicSelected);
    final chapter = ref.watch(chapterSelected);
    final links = chapter.links ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Center(
          child: Text(
            comic.name.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Center(
        child: links.isEmpty
            ? Text('This chapter is translating...')
            : CarouselSlider(
                items: links
                    .map(
                      (e) => Builder(
                        builder: (context) {
                          return Image.network(e, fit: BoxFit.cover);
                        },
                      ),
                    )
                    .toList(),
                options: CarouselOptions(
                  autoPlay: false,
                  height: MediaQuery.of(context).size.height,
                  enlargeCenterPage: false,
                  viewportFraction: 1,
                  initialPage: 0,
                ),
              ),
      ),
    );
  }
}
