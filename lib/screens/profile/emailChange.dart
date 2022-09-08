import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/screens/profile/profile_edit.dart';
import 'package:pet_app/services/auth.dart';
import 'package:pet_app/shared/constants.dart';

/// This page can change the password of the owner
class ChangeEmailScreen extends StatelessWidget {
  /// controler of the email
  final email = TextEditingController();

  /// controler of the password
  final password = TextEditingController();

  /// controler of the password confirmation
  final comfirm = TextEditingController();

  final _auth = AuthServices();

  @override
  Widget build(BuildContext context) {
    /// get the size of the screen, try to use percentage to manage the layout
    final size = MediaQuery.of(context).size;
    final widthL = size.width;
    return new Scaffold(
      appBar: new AppBar(),
      backgroundColor: Colors.blue,
      body: new ListView(children: [
        SizedBox(height: 20.0),
        /// enter the new email
        Container(
          width: widthL / 2,
          alignment: Alignment(0, 0),
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: email,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide()),
              prefixIcon: Icon(Icons.email),
              hintText: 'reset your email',
            ),
          ),
        ),
        /// enter your new password
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
        /// enter your new password again
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
            child: Text('Reset email >'),
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
                /// problem here about password reset
                _auth.changeUserEmail(email.text.trim(), comfirm.text.trim());
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              }
              /// If the two password are not the same, pop a hint and go back
              else {
                showDialog<Null>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      title: new Text('Error'),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            new Text('Two passwords are not the same!'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('try again'),
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
