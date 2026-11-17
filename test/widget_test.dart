import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('shows catalog and calculates receipt for a valid order', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    expect(find.text('Katalog Produk'), findsOneWidget);
    expect(find.text('Kopi Sidikalang 250 g'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('orderInput')), 'P01x2, P03x1');
    await tester.tap(find.byKey(const Key('processOrderButton')));
    await tester.pumpAndSettle();

    expect(find.text('Rp 115.000'), findsOneWidget);
    expect(find.text('Rp 11.500'), findsOneWidget);
    expect(find.text('Rp 103.500'), findsOneWidget);
    expect(find.text('Kopi'), findsWidgets);
    expect(find.text('Teh'), findsWidgets);
  });

  testWidgets('shows invalid order entries without crashing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byKey(const Key('orderInput')),
      'P01x2, XX99x1, P03xabc',
    );
    await tester.tap(find.byKey(const Key('processOrderButton')));
    await tester.pumpAndSettle();

    expect(find.text('XX99x1: Kode produk tidak ditemukan'), findsOneWidget);
    expect(
      find.text('P03xabc: Jumlah harus bilangan bulat positif'),
      findsOneWidget,
    );
    expect(find.text('Rp 90.000'), findsWidgets);
  });
}
