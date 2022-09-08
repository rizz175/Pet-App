import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/screens/profile/profile_present.dart';
import 'package:pet_app/services/database.dart';
import 'package:flutter_test/flutter_test.dart';
import './mock.dart';

main() {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });
  testWidgets('Profile Screen Widget test', (WidgetTester tester) async {
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

    await tester.pumpWidget(buildTestableWidget(
        ProfileScreen(firebaseFirestore: instance, auth: auth)));

    final titleFinder = find.text('Pick My Vet');
    expect(titleFinder, findsOneWidget);
  });
}
