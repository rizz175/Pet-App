// keep this page for testing purpose
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/screens/chat/chat_list.dart';
import 'package:pet_app/screens/profile/profile_present.dart';
import 'package:pet_app/screens/profile/friend_list.dart';
import 'package:pet_app/screens/profile/searchID.dart';
import 'package:pet_app/screens/maps/vet_map.dart';
import 'package:pet_app/screens/maps/world_map.dart';

// This homepage is for testing purposes (we need this).
class DummyHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home Screen'),
          actions: [
            FlatButton(
              child: Icon(Icons.cloud_off),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Center(
              child: RaisedButton(
                child: Text('go to my profile'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ProfileScreen(
                          firebaseFirestore: FirebaseFirestore.instance,
                          auth: FirebaseAuth.instance);
                    }),
                  );
                },
              ),
            ),
            Center(
              child: RaisedButton(
                child: Text('vet map'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return (MapScreen());
                    }),
                  );
                },
              ),
            ),
            Center(
              child: RaisedButton(
                child: Text('world map'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return (WorldMap());
                    }),
                  );
                },
              ),
            ),
            Center(
              child: RaisedButton(
                child: Text('others'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return (FriendListScreen());
                    }),
                  );
                },
              ),
            ),
            Center(
              child: RaisedButton(
                child: Text('search New Friend'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return (SearchIDScreen());
                    }),
                  );
                },
              ),
            ),
            Center(
              child: RaisedButton(
                child: Text('Chat List'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return (ChatListScreen());
                    }),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
