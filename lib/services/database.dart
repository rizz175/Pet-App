import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/models/park_model.dart';
import 'package:pet_app/models/store_model.dart';
import 'package:pet_app/models/vet_model.dart';

/// Service connect to the firestore the retrieve and send data
class FireStoreServices {
  String cuid;
  String email;
  CollectionReference _users;
  CollectionReference _vets;
  CollectionReference _parks;
  CollectionReference _stores;

  //final FirebaseAuth _auth = FirebaseAuth.instance;
  FireStoreServices(FirebaseFirestore instance, FirebaseAuth _auth) {
    cuid = _auth.currentUser.uid;
    email = _auth.currentUser.email;

    _users = instance.collection('Users');
    _vets = instance.collection('Vets');
    _parks = instance.collection('Parks');
    _stores = instance.collection('Stores');
  }

  /// Use user id in firestore to get the user name
  Future<String> getNameByUid(String uid) async {
    var snap = await _users.doc(uid).get();
    return (snap.data() as Map)['name'];
  }

  /// Create a new account with name, birthday, breed set
  Future newUser(
      {String uid,
      String name,
      DateTime dateTime,
      String breed,
      String currentDate,
      String email}) {
    _users.doc(uid).set({
      'name': name,
      'birthday': DateFormat('yyyy-MM-dd').format(dateTime),
      'breed': breed,
      'uid': uid,
      'friends': [],
      'notification': [],
      'location': null,
      'currentDate': currentDate,
      'exp': 0,
      'email': email,
    });
    return null;
  }

  /// Get the dog information from the snapshot of firestore
  Dog getDogFromSnap(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data();
    Dog dog = Dog(data['uid']);
    dog.name = data['name'];
    dog.birthday = data['birthday'];
    dog.breed = data['breed'];
    dog.gender = data['gender'];
    dog.weight = data['weight'].toString();
    dog.vetName = data['vetName'];
    return dog;
  }

  /// Get last park login date from cuid
  Future<String> getLoginDate() async {
    var snap = await _users.doc(cuid).get();
    Map<String, dynamic> data = snap.data();
    return data['currentDate'];
  }

  /// Get exp of cuid
  Future<int> getExp(String uid) async {
    var snap = await _users.doc(uid).get();
    Map<String, dynamic> data = snap.data();
    return data['exp'];
  }

  /// Get the dog profile from the user id
  Future<Dog> getUserObj(String uid) async {
    var snap = await _users.doc(uid).get();
    Map<String, dynamic> data = snap.data();
    Dog dog = Dog(uid);
    dog.name = data['name'];
    dog.birthday = data['birthday'];
    dog.breed = data['breed'];
    dog.gender = data['gender'];
    dog.weight = data['weight'].toString();
    dog.vetName = data['vetName'];
    return dog;
  }

  /// Get the dog profile from the user id
  Future<Dog> getChatUserObj(String uid, String friendUid) async {
    var snap = await _users.doc(friendUid).get();
    Map<String, dynamic> data = snap.data();
    Dog dog = Dog(friendUid);
    dog.name = data['name'];
    dog.birthday = data['birthday'];
    dog.breed = data['breed'];
    dog.gender = data['gender'];
    dog.weight = data['weight'].toString();
    dog.vetName = data['vetName'];

    final m = await FirebaseFirestore.instance
        .collection('messages/' + uid + '/' + friendUid)
        .orderBy('timestamp')
        .get();
    if (m.docs.length > 0) {
      dog.msg = m.docs.last.data()['text'];
      dog.msg_date = m.docs.last.data()['date'].toString();
      // dog.sortingTimestamp = m.docs.last.data()['timestamp'];
    } else {
      dog.msg = 'No messages';
      dog.msg_date = '';
    }

    return dog;
  }

  /// Get the vet list from the vet id
  Future<List<Vet>> getVetObj() async {
    List<Vet> fixedList = List();
    var snap = await _vets.get();
    for (int i = 0; i < snap.docs.length; i++) {
      var a = snap.docs[i];
      Map<String, dynamic> data = a.data();
      Vet vet = Vet(data['uid']);
      vet.clinicName = data['vet_name'];
      vet.address = data['address'];
      vet.description = data['description'];
      vet.thumbNail = data['thumbnail'];
      GeoPoint pos = data['location'];
      vet.locationCoords = new LatLng(pos.latitude, pos.longitude);

      vet.website = data['website'];

      fixedList.add(vet);
    }
    return fixedList;
  }

  /// Get the park from the park id
  Future<Park> getParkObj(String s) async {
    var snap = await _parks.doc().get();
    Map<String, dynamic> data = snap.data();
    Park park = Park(data['uid']);
    park.parkName = data['parkName'];
    park.address = data['address'];
    park.description = data['description'];
    GeoPoint pos = data['location'];
    park.locationCoords = new LatLng(pos.latitude, pos.longitude);
    park.cameraList =
        List.from(data['camera'].map((i) => i.toDouble()).toList());
    park.storeList = List.from(data['store']);
    park.vetWebsite = data['vetWebsite'];
    return park;
  }

  /// Get all parks from the database, return a parkList
  Future<List<Park>> getParksObj() async {
    List<Park> fixedList = List();
    var snap = await _parks.get();
    for (int i = 0; i < snap.docs.length; i++) {
      var a = snap.docs[i];
      Map<String, dynamic> data = a.data();
      Park park = Park(data['uid']);
      park.parkName = data['parkName'];
      park.address = data['address'];
      park.description = data['description'];
      GeoPoint pos = data['location'];
      park.locationCoords = new LatLng(pos.latitude, pos.longitude);
      park.storeList = List.from(data['store']);
      park.cameraList =
          List.from(data['camera'].map((i) => i.toDouble()).toList());
      park.vetWebsite = data['vetWebsite'];
      fixedList.add(park);
    }

    return fixedList;
  }

  /// Get all dogs from the database, return a dogList
  Future<List<Dog>> getAllUserObj() async {
    List<Dog> fixedList = List();
    var snap = await _users.get();
    for (int i = 0; i < snap.docs.length; i++) {
      var a = snap.docs[i];
      Map<String, dynamic> data = a.data();
      Dog dog = Dog(data['uid']);
      dog.name = data['name'];
      dog.birthday = data['birthday'];
      dog.breed = data['breed'];
      dog.gender = data['gender'];
      dog.weight = data['weight'].toString();
      GeoPoint pos = data['location'];
      dog.vetName = data['vetName'];
      if (pos != null && dog.uid != cuid) {
        dog.location = new LatLng(pos.latitude, pos.longitude);
        fixedList.add(dog);
      }
    }
    return fixedList;
  }

  /// Get store using uid from the database
  Future<Store> getStoreObj(String uid) async {
    var snap = await _stores.doc(uid).get();
    Map<String, dynamic> data = snap.data();
    Store store = Store(data['uid']);
    store.storeName = data['name'];
    store.website = data['website'];
    GeoPoint pos = data['location'];
    store.location = new LatLng(pos.latitude, pos.longitude);
    return store;
  }

  /// Update the profile into firestore
  void updateUserInfo(Dog dog) async {
    await _users.doc(dog.uid).update({
      'name': dog.name,
      'birthday': dog.birthday,
      'breed': dog.breed,
      'gender': dog.gender,
      'weight': dog.weight,
      'vetName': dog.vetName,
    });
  }

  void updateLoginDate(String date) async {
    await _users.doc(cuid).update({
      'currentDate': date,
    });
  }

  void updateExp(int exp) async {
    await _users.doc(cuid).update({
      'exp': exp,
    });
  }

  /// Update the location into firestore
  void updateLocationInfo(GeoPoint gp) async {
    await _users.doc(cuid).update({
      'location': gp,
    });
  }

  /// Get the friend of user by using user id
  Future<List> getFriendObj(String uid) async {
    List<dynamic> fixedList = List();
    var snap = await _users.doc(uid).get();
    Map<String, dynamic> data = snap.data();
    fixedList = data['friends'];
    return fixedList;
  }

  /// Get the notification list from the user id
  Future<List> getNotification(String uid) async {
    List<dynamic> fixedList = List();
    var snap = await _users.doc(uid).get();
    Map<String, dynamic> data = snap.data();
    fixedList = data['notification'];
    return fixedList;
  }

  /// Add new friend of user into the firestore
  void addFriendDouble(String uid) async {
    await _users.doc(cuid).update({
      'friends': FieldValue.arrayUnion([uid]),
    });
    await _users.doc(uid).update({
      'friends': FieldValue.arrayUnion([cuid]),
    });
  }

  /// Add new notification of user into the firestore
  void addNotification(String uid) async {
    await _users.doc(uid).update({
      'notification': FieldValue.arrayUnion([cuid]),
    });
  }

  /// Remove new notification of user into the firestore
  void removeNotification(String uid) async {
    await _users.doc(cuid).update({
      'notification': FieldValue.arrayRemove([uid]),
    });
  }

  /// Determine if the others are the friend of owner
  Future<bool> canAddFriend(String uid) async {
    List<dynamic> fixedList = List();
    if (cuid == uid) {
      return false;
    }
    var snap = await _users.doc(cuid).get();
    Map<String, dynamic> data = snap.data();
    fixedList = data['friends'];
    if (fixedList.contains(uid)) {
      return false;
    }
    return true;
  }

  /// Determine if the others have owner's notification
  Future<bool> haveNotificated(String uid) async {
    if (cuid == uid) {
      return false;
    }
    List<dynamic> fixedList = List();
    var snap = await _users.doc(uid).get();
    Map<String, dynamic> data = snap.data();
    fixedList = data['notification'];
    if (fixedList.contains(cuid)) {
      return true;
    }
    return false;
  }

  /// Use name to retrieve the specific users
  Future<List<Dog>> queryByName(String query) async {
    var snap = await _users.where('name', isEqualTo: query).get();
    var doglist = snap.docs.map(getDogFromSnap).toList();
    return doglist;
  }
}
