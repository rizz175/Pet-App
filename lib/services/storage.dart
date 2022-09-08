import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_app/services/database.dart';

/// connect to firebase storage
class StorageServices {
  Reference ref = FirebaseStorage.instance.ref().child('profile_images');
  Reference defaultPic = FirebaseStorage.instance.ref('default.png');
  FireStoreServices _fire =
      FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);

  Future uploadProfileImage(File image) async {
    try {
      await ref.child(_fire.cuid).putFile(image);
    } on FirebaseException catch (e) {
      print(e.code);
    }
  }

  /// return download url for profile image,
  /// if the user havn't upload any
  /// return the url for default profile image
  Future<String> getAvatarUrl({String uid = 'me'}) async {
    if (uid == 'me') {
      uid = _fire.cuid;
    }
    String url = await defaultPic.getDownloadURL();
    try {
      url = await ref.child(uid).getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found')
        print('retrive avatar picture error: ${e.code}');
    }
    return url;
  }
}
