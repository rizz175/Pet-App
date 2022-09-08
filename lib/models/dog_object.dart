import 'package:age/age.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Dog object that contain all infomation of one dog

/// Dog object. This is the class using which we create dog objects with their attributes.
class Dog {
  String uid;

  // public info
  String name;
  String gender;
  String birthday;
  String breed;
  LatLng location;

  String weight;
  String msg;
  String date;
  String msg_date;
  String sortingTimestamp;
  // private info
  String vetName;
  String email;

  Dog(this.uid);

  // Return formatted age string
  String get age {
    if (this.birthday == null) {
      return '';
    }

    var birth = DateTime.parse(this.birthday);
    AgeDuration age;
    age = Age.dateDifference(fromDate: birth, toDate: DateTime.now());

    return '${age.years}y ${age.months}m';
  }

  // Return empty if breed is null
  String get breedAsString {
    if (this.breed == null) return '';
    return this.breed;
  }
}
