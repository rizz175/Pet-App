import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:pet_app/models/vet_model.dart';
import 'package:pet_app/services/database.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/models/park_model.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('new user, get user object and update user test', () async {
    var instance = MockFirestoreInstance();
    var auth = MockFirebaseAuth();

    await auth.signInAnonymously();
    var _fire = FireStoreServices(instance, auth);
    DateTime timeInit = DateTime.parse('2020-11-14');
    await _fire.newUser(
        uid: 'n5F2P7hoh2VH5bEl7ObEFaQsFcE4',
        name: 'tester',
        dateTime: timeInit,
        breed: 'dog');

    Dog test = await _fire.getUserObj('n5F2P7hoh2VH5bEl7ObEFaQsFcE4');
    var name = test.name;
    var birthday = test.birthday;
    var breed = test.breed;
    var uid2 = test.uid;
    expect(name, 'tester');
    expect(birthday, '2020-11-14');
    expect(breed, 'dog');
    expect(uid2, 'n5F2P7hoh2VH5bEl7ObEFaQsFcE4');

    test.name = 'New name';

    _fire.updateUserInfo(test);

    Dog test2 = await _fire.getUserObj('n5F2P7hoh2VH5bEl7ObEFaQsFcE4');
    var name2 = test2.name;
    expect(name2, 'New name');
  });

  test('get name by ID test', () async {
    var instance = MockFirestoreInstance();
    var auth = MockFirebaseAuth();
    await auth.signInAnonymously();
    var _fire = FireStoreServices(instance, auth);
    DateTime timeInit = DateTime.parse('2020-11-14');
    await _fire.newUser(
        uid: 'n5F2P7hoh2VH5bEl7ObEFaQsFcE4',
        name: 'tester',
        dateTime: timeInit,
        breed: 'dog');

    var name = await _fire.getNameByUid('n5F2P7hoh2VH5bEl7ObEFaQsFcE4');
    expect(name, 'tester');
  });

  test('get vet object ', () async {
    var instance = MockFirestoreInstance();
    var auth = MockFirebaseAuth();
    await auth.signInAnonymously();
    var _fire = FireStoreServices(instance, auth);
    await instance.collection('Vets').add({
      'vet_name': 'vet 1',
      'address': 'testing location',
      'location': GeoPoint(55.7, -117.33),
      'uid': 'n5F2P7hoh2VH5bEl7ObEFaQsFcE4',
      'website': 'google.com',
    });

    List<Vet> vetList = await _fire.getVetObj();

    Vet test = vetList[0];

    var name = test.clinicName;
    var address = test.address;
    var website = test.website;
    var uid2 = test.uid;
    var location = test.locationCoords;
    expect(name, 'vet 1');
    expect(address, 'testing location');
    expect(website, 'google.com');
    expect(uid2, 'n5F2P7hoh2VH5bEl7ObEFaQsFcE4');
    expect(location, LatLng(55.7, -117.33));
  });

  test('get park test', () async {
    var instance = MockFirestoreInstance();
    var auth = MockFirebaseAuth();
    await auth.signInAnonymously();
    var _fire = FireStoreServices(instance, auth);
    await instance
        .collection('Parks')
        .doc('n5F2P7hoh2VH5bEl7ObEFaQsFcE4')
        .update({
      'parkName': 'tester',
      'address': 'addressTester',
      'description': 'descriptionTester',
      'uid': 'n5F2P7hoh2VH5bEl7ObEFaQsFcE4',
      'location': GeoPoint(55.7, -117.33),
    });

    Park test = await _fire.getParkObj('n5F2P7hoh2VH5bEl7ObEFaQsFcE4');
    var name = test.parkName;
    var address = test.address;
    var description = test.description;
    var uid2 = test.uid;
    var location = test.locationCoords;
    expect(name, 'tester');
    expect(address, 'addressTester');
    expect(description, 'descriptionTester');
    expect(uid2, 'n5F2P7hoh2VH5bEl7ObEFaQsFcE4');
    expect(location, LatLng(55.7, -117.33));
  });

  test('add and get friend test', () async {
    var instance = MockFirestoreInstance();
    var auth = MockFirebaseAuth();
    await auth.signInAnonymously();
    var _fire = FireStoreServices(instance, auth);
    DateTime timeInit = DateTime.parse('2020-11-14');
    await _fire.newUser(
        uid: 'IcTsosXaMTapTMk6Zf7l70whAbw1',
        name: 'tester1',
        dateTime: timeInit,
        breed: 'dog');
    await _fire.newUser(
        uid: auth.currentUser.uid,
        name: 'tester2',
        dateTime: timeInit,
        breed: 'dog');
    _fire.addFriendDouble('IcTsosXaMTapTMk6Zf7l70whAbw1');
    List test = await _fire.getFriendObj(auth.currentUser.uid);
    var friend = test[0];
    expect(friend, 'IcTsosXaMTapTMk6Zf7l70whAbw1');
    bool iftest1 = await _fire.canAddFriend('IcTsosXaMTapTMk6Zf7l70whAbw1');
    expect(iftest1, false);
    bool iftest2 = await _fire.canAddFriend('IcTsosXaMTapTMk6Zf7l70whAbw2');
    expect(iftest2, true);
  });

  test('add, remove and get notification test', () async {
    var instance = MockFirestoreInstance();
    var auth = MockFirebaseAuth();
    await auth.signInAnonymously();
    var _fire = FireStoreServices(instance, auth);
    DateTime timeInit = DateTime.parse('2020-11-14');
    await _fire.newUser(
        uid: 'IcTsosXaMTapTMk6Zf7l70whAbw1',
        name: 'tester1',
        dateTime: timeInit,
        breed: 'dog');
    await _fire.newUser(
        uid: auth.currentUser.uid,
        name: 'tester2',
        dateTime: timeInit,
        breed: 'dog');
    _fire.addNotification('IcTsosXaMTapTMk6Zf7l70whAbw1');
    List test = await _fire.getNotification('IcTsosXaMTapTMk6Zf7l70whAbw1');
    var iftest1 = test[0];
    expect(iftest1, auth.currentUser.uid);
    _fire.removeNotification('IcTsosXaMTapTMk6Zf7l70whAbw1');
    List test2 = await _fire.getNotification(auth.currentUser.uid);
    var iftest2 = test2;
    expect(iftest2, []);
  });
}
