import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/screens/profile/dog_list.dart';
import 'package:pet_app/services/database.dart';
import 'package:pet_app/screens/profile/searchID.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../notification/notification.dart';

/// This page is show all the friend owner have
/// Can be filtered by search area
/// Can search new friend
class FriendListScreen extends StatefulWidget {
  @override
  _FriendListScreen createState() => _FriendListScreen();
}

class _FriendListScreen extends State<FriendListScreen> {
  /// The enter name area
  TextEditingController editingController = TextEditingController();

  List<Dog> dogset;
  var items = List<Dog>();
  Dog dog;
  String oldname;
  FireStoreServices _fire;
  List idList;

  /// Get the infomation when the page start
  @override
  void initState() {
    dogset = [];
    _fire =
        FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
    FirebaseAuth _auth = FirebaseAuth.instance;
    String uid = _auth.currentUser.uid;

    /// Get the friend list in a list
    _fire.getFriendObj(uid).then((List i) {
      idList = i;

      /// Get the profile using the id in the list
      for (var i = 0; i < idList.length; i++) {
        _fire.getUserObj(idList[i].toString()).then((Dog d) {
          dog = d;
          dogset.add(dog);
          items.add(dog);
          setState(() {});
        });
      }

      /// Sorted the profile by user name
      Comparator<Dog> sortByName = (a, b) => a.name.compareTo(b.name);
      dogset.sort(sortByName);
      setState(() {});
    });

    super.initState();
  }

  /// Everytime enter some name, the items list will get the
  /// Profile in dogset list that have that name
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
    }

    /// If nothing enter, get the whole list
    else {
      setState(() {
        items.clear();
        items.addAll(dogset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend List'),
        actions: [
          FlatButton(
            child: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return SearchIDScreen();
              }),
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            _ListItem(Icons.notification_important, 'Friend Request',
                NotificationScreen()),
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

            /// List of the profile
            Expanded(
              child: DogList(doglist: items),
            ),
          ],
        ),
      ),
    );
  }
}

/// Public function that the owner will see the edit
/// Vistor will see the addFriend or nothing
class _ListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final StatefulWidget nextPage;
  _ListItem(this.icon, this.text, this.nextPage);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return nextPage;
          }),
        );
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 50,
            color: Colors.blue,
          ),
          SizedBox(width: 15),
          Text(text)
        ],
      ),
    );
  }
}
