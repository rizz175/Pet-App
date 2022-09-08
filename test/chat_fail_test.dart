import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

void main() {
  //TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'Fail test to check correct submission, the comparision is expected to return false',
      () async {
    // var chatRoom = new Chat(friendUid: 'KhbeWfxpAyNnepwRwKcC');
    var instance = MockFirestoreInstance();
    await instance
        .collection(
            'messages/' + '5crWuxFMuNY7E9G9xdz9' + '/' + 'KhbeWfxpAyNnepwRwKcC')
        .add({
      'text': 'Test message',
      'from': '5crWuxFMuNY7E9G9xdz9',
      'date': DateTime.now().toIso8601String().toString(),
    });
    final m = await instance
        .collection(
            'messages/' + '5crWuxFMuNY7E9G9xdz9' + '/' + 'KhbeWfxpAyNnepwRwKcC')
        .orderBy('date')
        .get();

    var dbMessage = m.docs.last.data()['text'].toString();
    String realMessage = 'Shouldnt pass';
    var results = (realMessage.compareTo(dbMessage));
    expect(-1, results);
  });
}
