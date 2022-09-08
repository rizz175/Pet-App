import 'package:flutter/material.dart';
import 'package:pet_app/screens/maps/vet_map.dart';
import 'package:pet_app/screens/profile/gamification_status_bars.dart';
import 'package:pet_app/screens/profile/profile_setting.dart';
import 'package:pet_app/screens/profile/public_user_info.dart';
import 'package:pet_app/services/database.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/shared/loading.dart';

///Constant text font style
var _tStyle1 = TextStyle(fontSize: 20);
double iconSize = 50;

/// This page is the profile page for the owner
/// It has the public infomation and vet infomation
class ProfileScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firebaseFirestore;

  ProfileScreen(
      {Key key, @required this.auth, @required this.firebaseFirestore})
      : super(key: key);
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  bool isLoading = true;

  Dog dog;
  FireStoreServices _fire;

  int exp;
  int level;

  // Get the dog infomation in th firestore
  void retriveDogInfo() {
    isLoading = true;
    _fire.getUserObj(_fire.cuid).then((Dog d) {
      setState(() {
        dog = d;
      });
    });
    _fire.getExp(_fire.cuid).then((int e) {
      setState(() {
        level = e ~/ 100;
        exp = e % 100;
        // print('$level, $exp');
        isLoading = false;
      });
    });
  }

  // Get the infomation when the page start
  @override
  void initState() {
    _fire = FireStoreServices(widget.firebaseFirestore, widget.auth);
    retriveDogInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        actions: [
          // Button to go to set profile
          FlatButton(
            child: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ProfileSetting();
                }),
              ).then((_) {
                retriveDogInfo();
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PublicUsrInfo(dog),

            // Vet info
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(40),
                child: Row(children: [
                  Icon(
                    Icons.local_hospital,
                    color: Colors.blue,
                    size: iconSize,
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      dog?.vetName == null ? 'Pick My Vet' : '${dog.vetName}',
                      style: _tStyle1,
                    ),
                  ),
                ]),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                ).then((_) {
                  retriveDogInfo();
                });
              },
            ),
            StatusBars(exp, level),
          ],
        ),
      ),
    );
  }
}
