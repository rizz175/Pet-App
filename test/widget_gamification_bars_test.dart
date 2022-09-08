import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/screens/profile/gamification_status_bars.dart';
import 'package:pet_app/screens/profile/profile_present.dart';
import 'package:pet_app/services/database.dart';
import 'package:flutter_test/flutter_test.dart';
import './mock.dart';

main() {
  testWidgets('Gamification Status bar test', (WidgetTester tester) async {
    Widget buildTestableWidget(Widget widget) {
      return MediaQuery(
          data: MediaQueryData(), child: MaterialApp(home: widget));
    }

    await tester.pumpWidget(buildTestableWidget(StatusBars()));

    final titleFinder = find.text('Strength: ');
    expect(titleFinder, findsOneWidget);
    final titleFinder2 = find.text('Speed: ');
    expect(titleFinder2, findsOneWidget);
    final titleFinder3 = find.text('Agility: ');
    expect(titleFinder3, findsOneWidget);
    final titleFinder4 = find.text('Intelligence: ');
    expect(titleFinder4, findsOneWidget);
    final titleFinder5 = find.text('Health: ');
    expect(titleFinder5, findsOneWidget);
    final titleFinder6 = find.text('Obedience: ');
    expect(titleFinder6, findsOneWidget);
  });
}
