import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';


// Mock classes
class MockFirebaseApp extends Mock implements FirebaseApp {}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  late MockFirebaseApp mockApp;
  late MockDatabaseReference mockRef;
  late MockDatabaseEvent mockEvent;
  late MockDataSnapshot mockSnapshot;

  setUp(() {
    mockApp = MockFirebaseApp();
    mockRef = MockDatabaseReference();
    mockEvent = MockDatabaseEvent();
    mockSnapshot = MockDataSnapshot();
  });

  // ─────────────────────────────────────────────
  // Unit Tests: getBanners()
  // ─────────────────────────────────────────────
  group('getBanners()', () {
    late _MyHomePageStateExposed state;

    setUp(() {
      state = _MyHomePageStateExposed();
    });

    test('คืนค่า [] เมื่อ snapshot.value เป็น null', () async {
      when(mockSnapshot.value).thenReturn(null);
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockRef.once()).thenAnswer((_) async => mockEvent);

      final result = await state.getBanners(mockRef);

      expect(result, isEmpty);
    });

    test('คืน URL list เมื่อ data เป็น List', () async {
      when(mockSnapshot.value).thenReturn([
        'https://example.com/banner1.jpg',
        'https://example.com/banner2.jpg',
      ]);
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockRef.once()).thenAnswer((_) async => mockEvent);

      final result = await state.getBanners(mockRef);

      expect(result, [
        'https://example.com/banner1.jpg',
        'https://example.com/banner2.jpg',
      ]);
    });

    test('คืน URL list เมื่อ data เป็น Map', () async {
      when(mockSnapshot.value).thenReturn({
        '0': 'https://example.com/banner1.jpg',
        '1': 'https://example.com/banner2.jpg',
      });
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockRef.once()).thenAnswer((_) async => mockEvent);

      final result = await state.getBanners(mockRef);

      expect(result, containsAll([
        'https://example.com/banner1.jpg',
        'https://example.com/banner2.jpg',
      ]));
    });

    test('คืนค่า [] เมื่อ data เป็น type ที่ไม่รองรับ', () async {
      when(mockSnapshot.value).thenReturn(12345);
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockRef.once()).thenAnswer((_) async => mockEvent);

      final result = await state.getBanners(mockRef);

      expect(result, isEmpty);
    });
  });

  // ─────────────────────────────────────────────
  // Widget Tests: MyHomePage UI
  // ─────────────────────────────────────────────
  group('MyHomePage Widget', () {
    Widget buildWidget({
      required Future<List<String>> Function(DatabaseReference) getBannersFn,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: MyHomePageTestable(
            title: 'Commic Reader App',
            app: mockApp,
            getBannersFn: getBannersFn,
          ),
        ),
      );
    }

    testWidgets('แสดง AppBar สีแดงพร้อม title', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        getBannersFn: (_) async => [],
      ));

      expect(find.text('Commic Reader App'), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color(0xFFF44A3E));
    });

    testWidgets('แสดง CircularProgressIndicator ขณะโหลดข้อมูล',
        (WidgetTester tester) async {
      final completer = Completer<List<String>>();

      await tester.pumpWidget(buildWidget(
        getBannersFn: (_) => completer.future,
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('แสดง CarouselSlider เมื่อโหลด banner สำเร็จ',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        getBannersFn: (_) async => [
          'https://example.com/banner1.jpg',
          'https://example.com/banner2.jpg',
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.byType(CarouselSlider), findsOneWidget);
    });

    testWidgets('แสดง error message เมื่อโหลด banner ล้มเหลว',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        getBannersFn: (_) async => throw Exception('Network error'),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });

    testWidgets('แสดง Image widget ตามจำนวน banner ที่ได้รับ',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        getBannersFn: (_) async => [
          'https://example.com/banner1.jpg',
          'https://example.com/banner2.jpg',
          'https://example.com/banner3.jpg',
        ],
      ));

      await tester.pumpAndSettle();

      // CarouselSlider render อย่างน้อย 1 image ในหน้า
      expect(find.byType(Image), findsWidgets);
    });
  });
}

// ─────────────────────────────────────────────
// Helper: expose getBanners() สำหรับ unit test
// ─────────────────────────────────────────────
class _MyHomePageStateExposed extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) => const SizedBox();

  Future<List<String>> getBanners(DatabaseReference bannerRef) async {
    final event = await bannerRef.once();
    final data = event.snapshot.value;

    if (data == null) return [];
    if (data is List) return data.map((e) => e.toString()).toList();
    if (data is Map) return data.values.map((e) => e.toString()).toList();
    return [];
  }
}

// ─────────────────────────────────────────────
// Helper: MyHomePage แบบ testable (inject getBannersFn)
// ─────────────────────────────────────────────
class MyHomePageTestable extends StatefulWidget {
  const MyHomePageTestable({
    super.key,
    required this.title,
    required this.app,
    required this.getBannersFn,
  });

  final String title;
  final FirebaseApp app;
  final Future<List<String>> Function(DatabaseReference) getBannersFn;

  @override
  State<MyHomePageTestable> createState() => _MyHomePageTestableState();
}

class _MyHomePageTestableState extends State<MyHomePageTestable> {
  late DatabaseReference _bannerRef;

  @override
  void initState() {
    super.initState();
    final db = FirebaseDatabase(app: widget.app);
    _bannerRef = db.ref().child('Banners');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<String>>(
        future: widget.getBannersFn(_bannerRef),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                CarouselSlider(
                  items: snapshot.data!
                      .map((e) => Builder(
                            builder: (context) =>
                                Image.network(e, fit: BoxFit.cover),
                          ))
                      .toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1,
                    height: MediaQuery.of(context).size.height / 3,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
