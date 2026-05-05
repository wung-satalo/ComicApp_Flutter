import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          databaseURL: 'https://reader-app-95191-default-rtdb.asia-southeast1.firebasedatabase.app/',
        )
      : FirebaseOptions(
          appId: '1:904073159015:android:42c4cab64559fde8598fc2',
          apiKey: 'AIzaSyCB7wOkEUqY48T5W5yp2E9OtpNCRRBe-i0',
          projectId: 'reader-app-95191',
          messagingSenderId: '904073159015',
          databaseURL: 'https://reader-app-95191-default-rtdb.asia-southeast1.firebasedatabase.app/',
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
      title: 'Reader App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Commic Reader App', app: app),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.app});

  final FirebaseApp app;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseReference _bannerRef, _comicsRef;

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: widget.app,
      databaseURL: 'https://reader-app-95191-default-rtdb.asia-southeast1.firebasedatabase.app/',
    );
    _bannerRef = database.ref().child('Banners');
    _comicsRef = database.ref().child('Comic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF44A3E),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
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
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                // ✅ แสดง loading ระหว่างโหลด
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                },
                                // ✅ แสดงภาพสำรองเมื่อโหลดไม่ได้
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, color: Colors.grey, size: 48),
                                        Text('โหลดรูปไม่ได้', style: TextStyle(color: Colors.grey)),
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
                        color: Colors.red,
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
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '',
                            style: TextStyle(color: Colors.white),
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
                        var comic = Comic.fromJson(jsonDecode(jsonEncode(item)));
                        comics.add(comic);
                      });
                      return Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          padding: const EdgeInsets.all(4.0),
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          children: comics.map((comic) {
                            return GestureDetector(
                              onTap: () {},
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
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Center(child: CircularProgressIndicator()),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                                Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    comic.name,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          color: Colors.grey.withValues(alpha: 0.7),
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  comic.name,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    overflow: TextOverflow.ellipsis,
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
}