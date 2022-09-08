import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/services/database.dart';
import 'package:pet_app/services/storage.dart';
import 'package:pet_app/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Chat extends StatefulWidget {
  static const String id = "CHAT";

  final String friendUid;

  const Chat({Key key, @required this.friendUid}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  FireStoreServices _fire;
  var _storage = StorageServices();

  String uid;
  String friendName;
  String myName;

  ImageProvider myAvatar;
  ImageProvider othersAvatar;

  bool isLoading = true;

  /// sets my uid and friends uid.

  @override
  void initState() {
    _fire =
        FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
    uid = _fire.cuid;

    ///retrieves friend name and uid
    _fire.getNameByUid(widget.friendUid).then((String n) {
      setState(() {
        friendName = n;
        _fire.getNameByUid(uid).then((String n) {
          setState(() {
            myName = n;
            _storage.getAvatarUrl().then((String url) {
              setState(() {
                myAvatar = NetworkImage(url);
              });
            });
            _storage.getAvatarUrl(uid: widget.friendUid).then((String url) {
              setState(() {
                othersAvatar = NetworkImage(url);
              });
            });

            isLoading = false;
          });
        });
      });
    });
    setState(() {});
    super.initState();
  }

  ///callback function adds message to my and my firends firebase chat histories
  Future<void> callback() async {
    print('in callback');
    if (messageController.text.length > 0) {
      await _firestore
          .collection('messages/' + uid + '/' + widget.friendUid)
          .add({
        'text': messageController.text,
        'from': uid,
        'date': DateTime.now().toIso8601String().toString(),
        'timestamp': FieldValue.serverTimestamp()
      });
      await _firestore
          .collection('messages/' + widget.friendUid + '/' + uid)
          .add({
        'text': messageController.text,
        'from': uid,
        'date': DateTime.now().toIso8601String().toString(),
        'timestamp': FieldValue.serverTimestamp()
      });
      messageController.clear();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  /// Chatting page with a edit text field and send button to store things in firebase
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text(friendName),
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    /// messages retrieved from current users chat history with friend on firebase.
                    /// ordered by date and time
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection(
                              'messages/' + uid + '/' + widget.friendUid)
                          .orderBy('timestamp')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(
                            child: CircularProgressIndicator(),
                          );

                        List<DocumentSnapshot> docs = snapshot.data.docs;

                        /// shows my message on right and friends on left side.
                        List<Widget> messages = docs
                            .map((doc) => Message(
                                  from: uid == (doc.data() as Map)['from']
                                      ? myName
                                      : friendName,
                                  text: (doc.data() as Map)['text'],
                                  me: uid == (doc.data() as Map)['from'],
                                  myAvatar: myAvatar,
                                  othersAvatar: othersAvatar,
                                ))
                            .toList();

                        return ListView(
                          controller: scrollController,
                          children: <Widget>[
                            ...messages,
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              onSubmitted: (value) => callback(),
                              decoration: InputDecoration(
                                hintText: "Enter a Message...",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                              ),
                              controller: messageController,
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                        SendButton(
                          text: "Send",
                          callback: callback,
                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      ],
                    ),
                  ),
                  SizedBox(height: 5)
                ],
              ),
            ),
          );
  }
}

/// send button activates callback function storing message in firebase
class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.yellow[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      onPressed: callback,
      child: Text(text),
    );
  }
}

class Message extends StatelessWidget {
  final String text;
  final String from;

  final bool me;
  final ImageProvider myAvatar;
  final ImageProvider othersAvatar;

  const Message(
      {Key key,
      this.from,
      this.text,
      this.me,
      this.myAvatar,
      this.othersAvatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          Row(
            mainAxisAlignment:
                me ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 7,
              ),
              me
                  ? SizedBox()
                  : CircleAvatar(
                      radius: 15,
                      backgroundImage: othersAvatar,
                    ),
              SizedBox(
                width: 7,
              ),
              Flexible(
                child: Bubble(
                  nip: me ? BubbleNip.rightTop : BubbleNip.leftTop,
                  color: me ? Colors.lightBlue[200] : Colors.grey[300],
                  elevation: 1.0,
                  alignment: me ? Alignment.topRight : Alignment.topLeft,
                  margin: me
                      ? BubbleEdges.only(top: 8.0, left: 50.0)
                      : BubbleEdges.only(top: 8.0, right: 50.0),
                  child: Text(
                    text,
                  ),
                ),
              ),
              SizedBox(
                width: 7,
              ),
              !me
                  ? SizedBox()
                  : CircleAvatar(
                      radius: 15,
                      backgroundImage: myAvatar,
                    ),
              SizedBox(
                width: 7,
              ),
            ],
          )
        ],
      ),
    );
  }
}
