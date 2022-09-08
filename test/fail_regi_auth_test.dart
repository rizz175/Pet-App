import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('test', () async {
    var instance = MockFirestoreInstance();
    await instance.collection('User').add({
      'name': 'tester',
      'birthday': '2020-11-14',
      'breed': 'dog',
      'uid': 'n5F2P7hoh2VH5bEl7ObEFaQsFcE4',
      'friends': [],
    });
    final m = await instance.collection('User').get();
    var name = m.docs.last.data()['name'];
    var birthday = m.docs.last.data()['birthday'];
    var breed = m.docs.last.data()['breed'];
    var uid = m.docs.last.data()['uid'];

    String realMessage = 'Shouldnt pass';
    var results = (realMessage.compareTo(name));
    expect(-1, results);
    results = (realMessage.compareTo(birthday));
    expect(1, results);

    results = (realMessage.compareTo(breed));
    expect(-1, results);

    results = (realMessage.compareTo(uid));
    expect(-1, results);
  });
}
