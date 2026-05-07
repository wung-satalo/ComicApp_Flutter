import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:comico/screen/chapter_screen.dart';
import 'package:comico/screen/read_screen.dart';
import 'package:comico/state/state_manager.dart';

import 'model/comic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'ReadApp',
    options: Platform.isMacOS || Platform.isIOS
        ? FirebaseOptions(
            appId: '1:904073159015:ios:db823ecf375628e3598fc2',
            apiKey: 'AIzaSyB-t3hPoPG2SZ0TU8Yn310_Nw84AFugRtU',
            projectId: 'reader-app-95191',
            messagingSenderId: '904073159015',
            databaseURL:
                'https://reader-app-95191-default-rtdb.asia-southeast1.firebasedatabase.app/',
          )
        : FirebaseOptions(
            appId: '1:904073159015:android:42c4cab64559fde8598fc2',
            apiKey: 'AIzaSyCB7wOkEUqY48T5W5yp2E9OtpNCRRBe-i0',
            projectId: 'reader-app-95191',
            messagingSenderId: '904073159015',
            databaseURL:
                'https://reader-app-95191-default-rtdb.asia-southeast1.firebasedatabase.app/',
          ),
  );
  runApp(ProviderScope(child: MyApp(app: app)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.app});

  final FirebaseApp app;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comico',
      routes: {
        '/chapters': (context) => ChapterScreen(),
        '/read': (context) => ReadScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Comico Read', app: app),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title, required this.app});

  final FirebaseApp app;
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  late DatabaseReference _bannerRef, _comicsRef;
  List<Comic> listComicFromFirebase = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _searchController.clear();
    ref.read(isSearch.notifier).state = false;
  }

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: widget.app,
      databaseURL:
          'https://reader-app-95191-default-rtdb.asia-southeast1.firebasedatabase.app/',
    );
    _bannerRef = database.ref().child('Banners');
    _comicsRef = database.ref().child('Comic');
  }

  @override
  Widget build(BuildContext context) {
    var searchEnable = ref.watch(isSearch);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: searchEnable
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _closeSearch,
              )
            : null,
        title: searchEnable
            ? TypeAheadField<Comic>(
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search comics...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    style: DefaultTextStyle.of(context).style.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  );
                },
                itemBuilder: (context, comic) {
                  return ListTile(
                    leading: Image.network(
                      comic.image,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 48,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    title: Text(comic.name),
                    subtitle: comic.category.isNotEmpty
                        ? Text(comic.category)
                        : null,
                  );
                },
                onSelected: (comic) {
                  ref.read(comicSelected.notifier).state = comic;
                  _closeSearch();
                  Navigator.pushNamed(context, '/chapters');
                },
                suggestionsCallback: (searchString) async {
                  return await searchComic(searchString);
                },
              )
            : Text(widget.title, style: TextStyle(color: Colors.white)),
        actions: [
          if (!searchEnable)
            IconButton(
              onPressed: () => ref.read(isSearch.notifier).state = true,
              icon: Icon(Icons.search),
              color: Colors.white,
            ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: getBanners(_bannerRef),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Carousel ---
                CarouselSlider(
                  items: snapshot.data?.map((e) {
                    return Builder(
                      builder: (context) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Image.network(
                                e,
                                width: double.infinity,
                                fit: BoxFit.cover,

                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 48,
                                        ),
                                        Text(
                                          'โหลดรูปไม่ได้',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.6),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    aspectRatio: 16 / 8,
                  ),
                ),

                // --- Header Row ---
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: Colors.teal,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'New Comics',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.new_releases_outlined,
                            color: Colors.teal,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // --- Comics Grid ---
                FutureBuilder(
                  future: getComics(_comicsRef),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      List<Comic> comics = [];
                      snapshot.data?.forEach((item) {
                        var comic = Comic.fromJson(
                          jsonDecode(jsonEncode(item)),
                        );
                        comics.add(comic);
                      });
                      listComicFromFirebase = comics;
                      return Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          padding: const EdgeInsets.all(4.0),
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          children: comics.map((comic) {
                            return GestureDetector(
                              onTap: () {
                                ref.read(comicSelected.notifier).state = comic;
                                Navigator.pushNamed(context, '/chapters');
                              },
                              child: Card(
                                elevation: 12,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        comic.image,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4.0,
                                                          ),
                                                      child: Text(
                                                        comic.name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.grey.withValues(
                                              alpha: 0.7,
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    comic.name,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List<String>> getBanners(DatabaseReference bannerRef) async {
    final event = await bannerRef.once();
    final data = event.snapshot.value;
    if (data == null) return [];
    if (data is List) return data.map((e) => e.toString()).toList();
    if (data is Map) return data.values.map((e) => e.toString()).toList();
    return [];
  }

  Future<List<dynamic>> getComics(DatabaseReference comicsRef) async {
    final event = await comicsRef.once();
    final data = event.snapshot.value;
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) return data.values.toList();
    return [];
  }

  Future<List<Comic>> searchComic(String searchString) async {
    if(searchString.length < 3) return [];
    return listComicFromFirebase
        .where(
          (comic) =>
              comic.name.toLowerCase().contains(searchString.toLowerCase()) ||
              (comic.category.isNotEmpty &&
                  comic.category.toLowerCase().contains(
                    searchString.toLowerCase(),
                  )),
        )
        .toList();
  }
}
