import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/services/database.dart';
import 'package:pet_app/services/storage.dart';
import 'package:pet_app/shared/my_flutter_app_icons.dart';

import '../../shared/loading.dart';

/// This page is for owner editing own profile infomation
class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isLoading = true;

  Dog dog;
  FireStoreServices _fire;
  String oldname;

  final name = TextEditingController();
  final weight = TextEditingController();
  var _storage = StorageServices();

  /// Key for form
  final _formKey1 = GlobalKey<FormState>();

  /// Get the infomation when the page start
  @override
  void initState() {
    isLoading = true;
    _fire =
        FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
    _fire.getUserObj(_fire.cuid).then((Dog d) {
      setState(() {
        dog = d;
        name.text = d.name;
        weight.text = d.weight;
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              shadowColor: Colors.transparent,
            ),
            backgroundColor: Colors.blue[300],
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey1,
                    child: Column(
                      children: [
                        /// Show the image
                        Center(
                          child: FutureBuilder(
                              future: _storage.getAvatarUrl(uid: dog?.uid),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundImage: !snapshot.hasData
                                      ? AssetImage('images/icon.png')
                                      : NetworkImage(snapshot.data),
                                );
                              }),
                        ),

                        /// Edit name
                        Container(
                          margin: const EdgeInsets.only(
                              left: 5.0, right: 5.0, top: 15.0, bottom: 15.0),
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.white, style: BorderStyle.solid),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              /// cancel underline
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.pets),
                              hintText: 'username',
                            ),

                            /// initialValue: dog?.name,
                            controller: name,

                            /// Some checking
                            validator: (val) {
                              /// If the name is empty, reject and send hint
                              if (val.isEmpty) {
                                return 'Enter a name';
                              }

                              /// If the name is too long, reject and send hint
                              else if (val.length > 20) {
                                return 'Name is too long.';
                              }
                              // Else, pass
                              else {
                                return null;
                              }
                            },
                            onChanged: (val) {
                              setState(() {
                                dog.name = val;
                              });
                            },
                          ),
                        ),

                        /// Select the gender
                        Column(
                          children: [
                            Text(
                              'Gender: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),

                            /// List to choose
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 5.0,
                                  right: 5.0,
                                  top: 15.0,
                                  bottom: 15.0),
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: DropdownButton(
                                isExpanded: true,
                                value: dog?.gender,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                                icon: Icon(Icons.arrow_downward),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dog.gender = newValue;
                                  });
                                },
                                underline: Container(
                                  height: 2,
                                  color: Colors.grey,
                                ),
                                dropdownColor: Colors.blue[200],
                                items: <String>[
                                  '',
                                  'Male',
                                  'Female',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),

                        /// Select the breed
                        Column(
                          children: [
                            Text(
                              'Breed: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),

                            /// List to choose
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 5.0,
                                  right: 5.0,
                                  top: 15.0,
                                  bottom: 15.0),
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: DropdownButton(
                                isExpanded: true,
                                value: dog?.breedAsString,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                                icon: Icon(Icons.arrow_downward),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dog.breed = newValue;
                                  });
                                },
                                underline: Container(
                                  height: 2,
                                  color: Colors.grey,
                                ),
                                dropdownColor: Colors.blue[200],
                                items: <String>[
                                  'Labrador Retriever',
                                  'Mixed',
                                  'German Shepard',
                                  'Shih Tzu',
                                  'Golden Retriver',
                                  'Chihuahua',
                                  'Pomeranian',
                                  'Yorkshire Terrier',
                                  'Labradoodle',
                                  'Dorder Collie',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),

                        // // Select gender and breed
                        // Row(children: [
                        //   // Gender text and chosen list
                        //   Expanded(
                        //     child: Column(children: [
                        //       Text(
                        //         'Gender: ',
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 20,
                        //         ),
                        //       ),

                        //       // List to choose
                        //       DropdownButton(
                        //         isExpanded: true,
                        //         value: dog?.gender,
                        //         style: TextStyle(color: Colors.white, fontSize: 18),
                        //         icon: Icon(Icons.arrow_downward),
                        //         onChanged: (String newValue) {
                        //           setState(() {
                        //             dog.gender = newValue;
                        //           });
                        //         },
                        //         underline: Container(
                        //           height: 2,
                        //           color: Colors.grey,
                        //         ),
                        //         dropdownColor: Colors.blue[200],
                        //         items: <String>[
                        //           '',
                        //           'Male',
                        //           'Female',
                        //         ].map<DropdownMenuItem<String>>((String value) {
                        //           return DropdownMenuItem<String>(
                        //             value: value,
                        //             child: Text(value),
                        //           );
                        //         }).toList(),
                        //       ),
                        //     ]),
                        //   ),

                        //   SizedBox(width: 10),

                        //   // Breed text and chosen list
                        //   Expanded(
                        //     child: Column(children: [
                        //       Text(
                        //         'Breed: ',
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 20,
                        //         ),
                        //       ),

                        //       // List of chosen
                        //       DropdownButton(
                        //         isExpanded: true,
                        //         value: dog?.breedAsString,
                        //         style: TextStyle(color: Colors.white, fontSize: 18),
                        //         icon: Icon(Icons.arrow_downward),
                        //         onChanged: (String newValue) {
                        //           setState(() {
                        //             dog.breed = newValue;
                        //           });
                        //         },
                        //         underline: Container(
                        //           height: 2,
                        //           color: Colors.grey,
                        //         ),
                        //         dropdownColor: Colors.blue[200],
                        //         items: <String>[
                        //           '',
                        //           'Labrador Retriever',
                        //           'Mixed',
                        //           'German Shepard',
                        //           'Shih Tzu',
                        //           'Golden Retriver',
                        //           'Chihuahua',
                        //           'Pomeranian',
                        //           'Yorkshire Terrier',
                        //           'Labradoodle',
                        //           'Dorder Collie',
                        //         ].map<DropdownMenuItem<String>>((String value) {
                        //           return DropdownMenuItem<String>(
                        //             value: value,
                        //             child: Text(value),
                        //           );
                        //         }).toList(),
                        //       ),
                        //     ]),
                        //   ),
                        // ]),

                        /// Edit weight
                        Container(
                          margin: const EdgeInsets.only(
                              left: 5.0, right: 5.0, top: 20.0, bottom: 15.0),
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.white, style: BorderStyle.solid),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              /// Cancel underline
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                MyFlutterApp.weight_hanging,
                              ),
                              hintText: 'weight',
                            ),

                            /// Weight will be number or empty
                            controller: weight,

                            /// Only let to enter digits
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'))
                            ],

                            /// Some checking
                            validator: (val) {
                              /// If weight is empty, reject and send hint
                              if (val.isEmpty) {
                                return 'Enter a weight';
                              }

                              /// If weight is non-number, reject and send hint
                              else if (double.tryParse(val) == null) {
                                return 'Please enter a number.';
                              }
                              // Else, pass
                              else {
                                return null;
                              }
                            },
                            onChanged: (val) {
                              setState(() {
                                dog.weight = val;
                              });
                            },
                          ),
                        ),

                        /// Set the birthday
                        Column(
                          children: [
                            Text(
                              'Date of birth: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                color: Colors.white,
                                child: Text(
                                  dog?.birthday ?? 'loading...',
                                  style: TextStyle(
                                      color: dog?.birthday == null
                                          ? Colors.grey[500]
                                          : Colors.black,
                                      fontSize: 15),
                                ),
                                onPressed: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.parse(dog.birthday),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  ).then((date) {
                                    setState(() {
                                      dog.birthday =
                                          DateFormat('yyyy-MM-dd').format(date);
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Button to save the change
            floatingActionButton: new FloatingActionButton(
              child: Icon(Icons.save),
              backgroundColor: Colors.lightBlue,
              onPressed: () async {
                if (_formKey1.currentState.validate()) {
                  _fire.updateUserInfo(dog);
                  Navigator.pop(context, true);
                }
              },
            ),
          );
  }
}
