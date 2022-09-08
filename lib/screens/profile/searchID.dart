import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/screens/profile/dog_list.dart';
import 'package:pet_app/services/database.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// This page is about search a user by entering user name
class SearchIDScreen extends StatefulWidget {
  @override
  _SearchIDScreenState createState() => _SearchIDScreenState();
}

class _SearchIDScreenState extends State<SearchIDScreen> {
  // Controler of the text input
  final resultController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FireStoreServices _fire =
      FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
  Dog dog;
  List<Dog> dogset = [];

  /// Update the set of short profile in the listLiew once we enter something
  void querry() async {
    var result = await _fire.queryByName(resultController.text);
    setState(() {
      dogset = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Search new friend'),
      ),
      body: Column(
        children: [
          // Search input area
          TextField(
            controller: resultController,
            decoration: InputDecoration(
              labelText: "Search by name",
              hintText: "Search by name",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(25.0),
                ),
              ),
            ),
          ),
          // Button to seach
          RaisedButton(
            onPressed: querry,
            child: Text('Search'),
          ),
          // List of the short profile
          Expanded(child: DogList(doglist: dogset)),
        ],
      ),
    );
  }
}
