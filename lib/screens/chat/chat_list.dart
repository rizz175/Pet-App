import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/screens/chat/dog_list_chat.dart';
import 'package:pet_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///Chat list shows your list of friends with whom you are chatting with

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreen createState() => _ChatListScreen();
}

class _ChatListScreen extends State<ChatListScreen> {
  TextEditingController editingController = TextEditingController();

  List<Dog> dogset = [];
  List<String> lastmsg = [];
  List<String> lastDate = [];
  List<String> lastTime = [];
  var items = List<Dog>();
  Dog dog;
  String oldname;
  FireStoreServices _fire =
      FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
  String emailS;
  List idList;

  String msgDate;

  /// Retrieves all dog objects (who are friends with current dog user object) from firebase and stores them  in a list
  /// Retrieves chat history (lastmsg, last message date and time) between current dog user object and each retrieved dog
  /// user object and stores them in a list
  @override
  void initState() {
    _fire =
        FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
    FirebaseAuth _auth = FirebaseAuth.instance;
    String uid = _auth.currentUser.uid;
    emailS = _auth.currentUser.email;

    /// get the friend list in a list
    _fire.getFriendObj(uid).then((List i) {
      idList = i;

      /// get the profile using the id in the list
      for (var i = 0; i < idList.length; i++) {
        _fire.getChatUserObj(_fire.cuid, idList[i].toString()).then((Dog d) {
          dog = d;
          dogset.add(dog);
          lastmsg.add(dog.msg);
          items.add(dog);
          if (dog.msg_date == '') {
            lastDate.add('');
            lastTime.add('');
          } else {
            msgDate = dog.msg_date;
            var split = msgDate.split('T');
            lastDate.add(split[0]);
            lastTime.add(split[1].split('.')[0]);
          }
          setState(() {});
        });

        // Sorting by the timestamp by user name
        // Comparator<Dog> sortByTime =
        //     (a, b) => a.sortingTimestamp.compareTo(b.sortingTimestamp);
        // dogset.sort(sortByTime);
        // setState(() {});
      }
    });
    super.initState();
  }

  ///filters search results in the search bar
  void filterSearchResults(String query) {
    List<Dog> dummySearchList = List<Dog>();
    dummySearchList.addAll(dogset);
    if (query.isNotEmpty) {
      List<Dog> dummyListData = List<Dog>();
      dummySearchList.forEach((item) {
        if (item.name.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(dogset);
      });
    }
  }

  /// widget built for the chat page with title chats and search functionality
  /// with a list view showing list of all friends
  @override
  Widget build(BuildContext context) {
    print(lastmsg);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search by Name",
                    hintText: "Search by Name",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),

            /// returns the list view
            Expanded(
              child: DogListChat(
                  doglist: items,
                  last_msg: lastmsg,
                  last_date: lastDate,
                  last_time: lastTime),
            ),
          ],
        ),
      ),
    );
  }
}
