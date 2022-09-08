import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/screens/profile/profile_setting.dart';
import 'package:pet_app/services/database.dart';
import 'package:flutter_test/flutter_test.dart';
import './mock.dart';

main() {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Profile Setting Widget test', (WidgetTester tester) async {
    var instance = MockFirestoreInstance();
    var auth = MockFirebaseAuth();

    await auth.signInAnonymously();
    var _fire = FireStoreServices(instance, auth);
    DateTime timeInit = DateTime.parse('2020-11-14');
    await _fire.newUser(
        uid: auth.currentUser.uid,
        name: 'tester',
        dateTime: timeInit,
        breed: 'dog');

    Widget buildTestableWidget(Widget widget) {
      return MediaQuery(
          data: MediaQueryData(), child: MaterialApp(home: widget));
    }

    await tester.pumpWidget(buildTestableWidget(ProfileSetting()));

    final titleFinder = find.text('Account Setting');
    expect(titleFinder, findsOneWidget);
    final titleFinder2 = find.text('Dog profile');
    expect(titleFinder2, findsOneWidget);
    final titleFinder3 = find.text('Upload profile picture');
    expect(titleFinder3, findsOneWidget);
  });
}
