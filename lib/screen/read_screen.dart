import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comico/state/state_manager.dart';

class ReadScreen extends ConsumerWidget {
  const ReadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comic = ref.watch(comicSelected);
    final chapter = ref.watch(chapterSelected);
    final links = chapter.links;
    final readingMode = ref.watch(readingModeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            comic.name.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            tooltip: readingMode == ReadingMode.horizontal
                ? 'Switch to Vertical Scroll'
                : 'Switch to Horizontal Slide',
            icon: Icon(
              readingMode == ReadingMode.horizontal
                  ? Icons.swap_vert
                  : Icons.swap_horiz,
              color: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(readingModeProvider.notifier)
                  .state = readingMode == ReadingMode.horizontal
                  ? ReadingMode.vertical
                  : ReadingMode.horizontal;
            },
          ),
        ],
      ),

      body: Center(
        child: links.isEmpty
            ? const Text('This chapter is translating...')
            : readingMode == ReadingMode.horizontal
            ? _HorizontalReader(links: links)
            : _VerticalReader(links: links),
      ),
    );
  }
}

class _HorizontalReader extends StatelessWidget {
  final List<String> links;
  const _HorizontalReader({required this.links});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: links
          .map(
            (e) => Builder(
              builder: (context) => Image.network(e, fit: BoxFit.contain),
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
    );
  }
}

class _VerticalReader extends StatelessWidget {
  final List<String> links;
  const _VerticalReader({required this.links});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: links.length,
      itemBuilder: (context, index) => Image.network(
        links[index],
        fit: BoxFit.fitWidth,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
