import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class LinkSocialMedia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            FacebookSignInButton(
                text: "Link with Facebook",
                onPressed: () {
                  print("facebook onpressed");
                }),
            GoogleSignInButton(
              onPressed: () {
                googleLogin();
              },
              darkMode: true,
              text: "Link with Google",
            ),
          ],
        ),
      ),
    );
  }

  void googleLogin() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        // you can add extras if you require
      ],
    );

    _googleSignIn.signIn().then((GoogleSignInAccount acc) async {
      GoogleSignInAuthentication auth = await acc.authentication;
      print(acc.id);
      print(acc.email);
      print(acc.displayName);
      print(acc.photoUrl);

      acc.authentication.then((GoogleSignInAuthentication auth) async {
        print(auth.idToken);
        print(auth.accessToken);
      });
    });
  }
}

void facebookLogin() async{
  
}
