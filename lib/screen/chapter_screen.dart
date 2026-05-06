import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_app/state/state_manager.dart';

class ChapterScreen extends ConsumerWidget {
  const ChapterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comic = ref.watch(comicSelected);

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
      body: comic.chapters.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: comic.chapters.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {

                      ref.read(chapterSelected.notifier).state = comic.chapters[index];
                      Navigator.pushNamed(context, '/read');

                    },
                    child: Column(
                      children: [
                        ListTile(title: Text('${comic.chapters[index].name}')),
                        const Divider(thickness: 1),
                      ],
                    ),
                  );
                },
              ),
            )
          : const Center(child: Text('We are translating this comic.')),
    );
  }
}
