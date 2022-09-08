import 'package:flutter/material.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/screens/profile/other_profile.dart';
import 'package:pet_app/services/storage.dart';

// This page is the dog short profile in the friend list and chat list
class RequestList extends StatefulWidget {
  final List<Dog> doglist;

  // This page required list of dog profile
  RequestList({Key key, @required this.doglist}) : super(key: key);

  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  var _storage = StorageServices();
  @override
  Widget build(BuildContext context) {
    // The short profile have the image, name, breed
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
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      alignment: Alignment.bottomCenter,
                      child: new Text(
                        widget.doglist[index].name,
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      alignment: Alignment.bottomCenter,
                      child: new Text(
                        'just send you a friend request',
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return OtherProScreen(uid: widget.doglist[index].uid);
                    }),
                        ),
                      );
                  }
                );
            }
          );
  }
}
