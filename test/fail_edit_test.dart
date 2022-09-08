import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('fail editing with worng input', () async {
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
    expect(name, 'tester');
    expect(birthday, '2020-11-14');
    expect(breed, 'dog');
    expect(uid, 'n5F2P7hoh2VH5bEl7ObEFaQsFcE4');

    await instance.collection('User').doc().update({
      'name': 'new tester',
    });

    final n = await instance.collection('User').get();

    var name2 = n.docs.last.data()['name'];
    String realMessage = 'Shouldnt pass';
    var results = (realMessage.compareTo(name2));
    expect(-1, results);
  });
}
