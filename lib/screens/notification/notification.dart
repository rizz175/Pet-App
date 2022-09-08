import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/services/database.dart';
import '../notification/request_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreen createState() => _NotificationScreen();
}

class _NotificationScreen extends State<NotificationScreen> {
  List<Dog> dogset;
  Dog dog;
  FireStoreServices _fire;
  List notification;
  // Get the infomation when the page start
  @override
  void initState() {
    dogset = [];
    _fire =
        FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
    FirebaseAuth _auth = FirebaseAuth.instance;
    String uid = _auth.currentUser.uid;
    // Get the friend list in a list
    _fire.getNotification(uid).then((List i) {
      notification = i;
      // Get the profile using the id in the list
      for (var i = 0; i < notification.length; i++) {
        _fire.getUserObj(notification[i].toString()).then((Dog d) {
          print(notification[i]);
          dog = d;
          dogset.add(dog);
          setState(() {});
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Request List'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            // List of the profile
            Expanded(
              child: RequestList(doglist: dogset),
            ),
          ],
        ),
      ),
    );
  }
}
