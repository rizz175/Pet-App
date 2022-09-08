import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pet_app/services/database.dart';

class MockFireStorage extends Mock implements FirebaseStorage {}

void main() {
  test('Mock storage test', () async {
    var instance = MockFirestoreInstance();
    var auth = MockFirebaseAuth();
    MockFireStorage mockFireStorage = MockFireStorage();
    Reference ref = mockFireStorage.ref().child('profile_images');
    Reference dog = mockFireStorage.ref('default.png');
    FireStoreServices _fire = FireStoreServices(instance, auth);
  });
}
