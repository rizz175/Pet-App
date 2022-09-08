import 'package:flutter/material.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/screens/chat/chat.dart';
import 'package:pet_app/services/storage.dart';

class DogListChat extends StatefulWidget {
  final List<Dog> doglist;
  final List<String> last_msg;
  final List<String> last_date;
  final List<String> last_time;
  DogListChat(
      {Key key,
      @required this.doglist,
      @required this.last_msg,
      @required this.last_date,
      @required this.last_time})
      : super(key: key);

  @override
  _DogListChatState createState() => _DogListChatState();
}

/// list view of all the friend chats, displaying friend name, last message and date and time of message
class _DogListChatState extends State<DogListChat> {
  var _storage = StorageServices();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: new EdgeInsets.all(5.0),
        itemExtent: 50.0,
        itemCount: widget.doglist.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder<String>(
              future: _storage.getAvatarUrl(uid: widget.doglist[index].uid),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                ImageProvider imageProvider;
                if (snapshot.hasData) {
                  imageProvider = NetworkImage(snapshot.data);
                } else {
                  imageProvider = AssetImage('images/icon.png');
                }

                return GestureDetector(
                  child: Row(children: [
                    Container(
                      height: 50,
                      child: new CircleAvatar(
                        radius: 20,
                        backgroundImage: imageProvider,
                      ),
                    ),
                    Expanded(
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.only(left: 10, bottom: 5),
                          alignment: Alignment.topLeft,
                          child: new Text(
                            widget.doglist.isEmpty
                                ? ''
                                : widget.doglist[index].name,
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10, top: 5),
                          alignment: Alignment.bottomLeft,
                          child: new Text(
                            widget.last_msg.isEmpty
                                ? ''
                                : widget.last_msg[index].toString(),
                            style: new TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ),
                    Column(children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 5),
                        alignment: Alignment.topRight,
                        child: new Text(
                          widget.last_date.isEmpty
                              ? ''
                              : widget.last_date[index],
                          style: new TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        alignment: Alignment.bottomRight,
                        child: new Text(
                          widget.last_time.isEmpty
                              ? ''
                              : widget.last_time[index],
                          style: new TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return Chat(friendUid: widget.doglist[index].uid);
                    }),
                  ),
                );
              });
        });
  }
}
