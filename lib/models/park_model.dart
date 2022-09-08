import 'package:google_maps_flutter/google_maps_flutter.dart';

///Park classs, with all park attributes
class Park {
  String uid;
  String parkName;
  String address;
  String description;
  List<String> userList;
  LatLng locationCoords;
  List<String> storeList;
  List<double> cameraList;
  String vetWebsite;
  Park(this.uid);
}
