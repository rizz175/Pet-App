import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pet_app/screens/chat/chat.dart';
import 'package:pet_app/screens/profile/gamification_status_bars.dart';
import 'package:pet_app/screens/profile/public_user_info.dart';
import 'package:pet_app/services/database.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// This page is the profile infomation show to the visitor
/// It only have the public infomation and add friend button (no button if they are already friend)
class OtherProScreen extends StatefulWidget {
  final String uid;

  /// This page is required an user id
  OtherProScreen({Key key, @required this.uid}) : super(key: key);

  @override
  _OtherProScreen createState() => new _OtherProScreen();
}

class _OtherProScreen extends State<OtherProScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = true;

  Dog dog;
  FireStoreServices _fire;
  bool canAddFriend;
  bool haveNotificated;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List notification;
  int exp;
  int level;

  /// Get the dog infomation in th firestore
  void firebaseInteraction() {
    isLoading = true;
    _fire.getUserObj(widget.uid).then((Dog d) {
      setState(() {
        dog = d;
      });
    });
    _fire.getNotification(_fire.cuid).then((List li) {
      setState(() {
        notification = li;
      });
    });
    _fire.canAddFriend(widget.uid).then((bool b) {
      setState(() {
        canAddFriend = b;
      });
    });
    _fire.haveNotificated(widget.uid).then((bool b) {
      setState(() {
        haveNotificated = b;
        isLoading = false;
      });
    });
    _fire.getExp(widget.uid).then((int e) {
      setState(() {
        level = e ~/ 100;
        exp = e % 100;
        isLoading = false;
      });
    });
  }

  /// Get the infomation when the page start
  @override
  void initState() {
    _fire =
        FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
    firebaseInteraction();
    super.initState();
  }

  ///callback function adds message to my and my firends firebase chat histories
  Future<void> callback(Dog dog) async {
    String info = await _fire.getNameByUid(_fire.cuid) + " just follow you";
    await _firestore
        .collection('messages/' + _fire.cuid + '/' + widget.uid)
        .add({
      'text': info,
      'from': _fire.cuid,
      'date': DateTime.now().toIso8601String().toString(),
    });
    await _firestore
        .collection('messages/' + widget.uid + '/' + _fire.cuid)
        .add({
      'text': info,
      'from': _fire.cuid,
      'date': DateTime.now().toIso8601String().toString(),
    });
  }

  void checkNotification(Dog dog) async {
    if (notification != null) {
      if (notification.contains(dog.uid)) {
        _fire.removeNotification(dog.uid);
        _fire.addFriendDouble(dog.uid);
      } else {
        // send others a notification
        _fire.addNotification(dog.uid);
      }
    } else {
      _fire.addNotification(dog.uid);
    }
  }

  void _friendAddButtonPress() {
    if (haveNotificated) {
      return null;
    } else {
      /// Basic version just add friend, no other statement
      checkNotification(dog);
      callback(dog);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('canaddfriend: $canAddFriend');
    print('notif: $haveNotificated');
    return isLoading
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              shadowColor: Colors.transparent,
              actions: [
                /// Check if they are not friend
                !canAddFriend

                    /// If yes, check if they are in the notification list
                    ? GestureDetector(
                        child: Container(
                          margin: EdgeInsets.all(15.0),
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Center(
                              child: Text('Chat',
                                  style: TextStyle(color: Colors.white))),
                        ),
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return Chat(friendUid: widget.uid);
                              }),
                            ))

                    /// If no, show add friend button
                    : GestureDetector(
                        child: Container(
                          margin: EdgeInsets.all(15.0),
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.white),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Center(
                              child: Text(
                                  haveNotificated ? 'Pending' : 'Add Friend',
                                  style: TextStyle(color: Colors.blue))),
                        ),
                        onTap: () {
                          _friendAddButtonPress();
                          var snackBar = SnackBar(
                              duration: const Duration(seconds: 2),
                              content: new Text(
                                  "You have send friend request successfully!"));
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                          firebaseInteraction();
                        },
                      ),
              ],
            ),

            /// Only show the public infomation of the profile for visitor
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PublicUsrInfo(dog),
                  SizedBox(height: 40),
                  StatusBars(exp, level)
                ],
              ),
            ));
  }
}
