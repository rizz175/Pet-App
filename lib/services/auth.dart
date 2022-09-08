import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/services/database.dart';

/// This services is the auth service that for user account
class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookSignIn = FacebookAuth.instance;

  /// sign up with email and password and create new user with their personal information
  Future<void> createUserWithEmailAndPassword(
      {String email,
      String password,
      String name,
      DateTime dateTime,
      String breed,
      String currentDate}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      String uid = _auth.currentUser.uid;
      FireStoreServices f =
          FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
      await f.newUser(
          uid: uid,
          name: name,
          dateTime: dateTime,
          breed: breed,
          currentDate: currentDate,
          email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else if (e.code == 'weak-password') {
        throw Exception('The account already exists for that email.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// login with email and password
  Future<User> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    User user;
    try {
      user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception(e.code);
      } else if (e.code == 'wrong-password') {
        throw Exception(e.code);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
    return user;
  }

  Future<void> signInWithGoogle() async {
    // hold the instance of the authenticated user
    User user;
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      user = userCredential.user;
      if (userCredential.additionalUserInfo.isNewUser) {
        FireStoreServices f = FireStoreServices(
            FirebaseFirestore.instance, FirebaseAuth.instance);
        await f.newUser(
            uid: user.uid,
            name: user.displayName,
            dateTime: DateTime.now(),
            breed: 'Mixed',
            currentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            email: user.email);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signInWithFacebook() async {
    User user;
    try {
      final LoginResult loginResult = await _facebookSignIn.login();
      final OAuthCredential oAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken.token);
      UserCredential userCredential =
          await _auth.signInWithCredential(oAuthCredential);
      user = userCredential.user;
      if (userCredential.additionalUserInfo.isNewUser) {
        FireStoreServices f = FireStoreServices(
            FirebaseFirestore.instance, FirebaseAuth.instance);
        await f.newUser(
            uid: user.uid,
            name: user.displayName,
            dateTime: DateTime.now(),
            breed: 'Mixed',
            currentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            email: user.email);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _facebookSignIn.logOut();
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Change user login email
  void changeUserEmail(String newEmail, String newPassword) {
    String msg;
    try {
      User user = _auth.currentUser;
      user.updateEmail(newEmail).then((_) async {
        UserCredential authResult = await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: newEmail,
            password: newPassword,
          ),
        );
        msg = 'success';
      });
    } catch (e) {
      msg = e.message;
      print('changeUserEmail error: $msg');
    }
  }

  /// Change user login password
  void changeUserPassword(String newPassword) {
    String msg;
    try {
      User user = _auth.currentUser;
      user.updatePassword(newPassword).then((_) {
        msg = 'success';
      });
    } catch (e) {
      msg = e.message;
      print('changeUserPassword error: $msg');
    }
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _auth.currentUser;
    return currentUser != null;
  }

  Future<String> getUser() async {
    return (await _auth.currentUser).email;
  }
}
