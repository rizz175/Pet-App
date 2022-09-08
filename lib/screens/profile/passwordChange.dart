import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/screens/profile/profile_edit.dart';
import 'package:pet_app/services/auth.dart';

/// This page can change the password of the owner
class ChangePassScreen extends StatelessWidget {
  // controler of the password
  final password = TextEditingController();
  // controler of the password confirmation
  final comfirm = TextEditingController();

  final _auth = AuthServices();

  @override
  Widget build(BuildContext context) {
    /// get the size of the screen, try to use percentage to manage the layout
    final size = MediaQuery.of(context).size;
    final widthL = size.width;

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.blue,
      body: ListView(children: [
        SizedBox(height: 20.0),
        Container(
          width: widthL / 2,
          alignment: Alignment(0, 0),
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: password,
            obscureText: true,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide()),
              prefixIcon: Icon(Icons.lock),
              hintText: 'reset your password',
            ),
          ),
        ),
        Container(
          width: widthL / 2,
          alignment: Alignment(0, 0),
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: comfirm,
            obscureText: true,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide()),
              prefixIcon: Icon(Icons.lock),
              hintText: 'repeat your password',
            ),
          ),
        ),
        Container(
          alignment: Alignment(1, -1),
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          child: FlatButton(
            child: Text('Reset Password >'),
            color: Colors.white,
            textColor: Colors.black,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(20)),
            onPressed: () async {
              /// If the password and confirm password are the same, update
              if (password.text == comfirm.text) {
                // problem here about password reset
                _auth.changeUserPassword(comfirm.text.trim());
                Navigator.pop(context, true);
              }

              /// If the two password are not the same, pop a hint and go back
              else {
                showDialog<Null>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Two passwords are not the same!'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('try again'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                ).then((val) {
                  print(val);
                });
              }
            },
          ),
        ),
      ]),
    );
  }
}
