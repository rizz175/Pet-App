import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

// import 'package:pet_book/screens/chat/chat.dart';

void main() {
  //TestWidgetsFlutterBinding.ensureInitialized();
  test('Test chatroom handling new message submission', () async {
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
    String realMessage = 'Test message';
    var results = (realMessage.compareTo(dbMessage));
    expect(0, results);
  });
}
