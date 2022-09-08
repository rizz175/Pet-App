import 'dart:async';
import 'dart:core';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_app/screens/chat/chat_list.dart';
import 'package:pet_app/screens/profile/profile_present.dart';
import 'package:pet_app/screens/profile/friend_list.dart';
import 'package:pet_app/screens/maps/park_map.dart';
import 'package:location/location.dart';
import 'package:pet_app/models/park_model.dart';
import 'package:pet_app/services/database.dart';
import 'package:pet_app/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart' as geocod;

/// home page, include buttons access to our features, include park marker icons
class WorldMap extends StatefulWidget {
  @override
  _WorldMapState createState() => _WorldMapState();
}

class _WorldMapState extends State<WorldMap> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Marker> markerList = [];
  GoogleMapController _controller;
  BitmapDescriptor _markerIcon;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  StreamSubscription<LocationData> locationSubscription;
  LocationData currentLocation;
  Location location;
  static LatLng _initialPosition = LatLng(53.513954, -113.486396);
  List<Park> parkList;
  FireStoreServices _fire;
  GeoPoint point;
  String placeName;
  List<String> parkNames = [];

  /// current date
  StreamSubscription<DateTime> datetimeSubscription;
  DateTime currentTime = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String formattedDate;
  int exp;

  final String parkImage = "assets/park-image.svg";
  bool isSwitched = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    location = new Location();
    _fire =
        FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
    firebaseInteraction();

    /// stream to current date
    datetimeListenerInit();

    /// set the initial location
    setInitialLocation();

    /// subscribe to changes in the user's location
    /// by "listening" to the location's onLocationChanged event
    locationListenerInit();

    /// set custom marker pins
    _setMarkerIcon();
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    datetimeSubscription.cancel();
    super.dispose();
  }

  /// Get the park infomation in the firestore
  Future<void> firebaseInteraction() async {
    isLoading = true;
    _fire.getExp(_fire.cuid).then((int e) {
      setState(() {
        exp = e;
      });
    });
    _fire.getParksObj().then((List<Park> pl) {
      pl.forEach((p) => parkNames.add(p.parkName));
      setState(() {
        parkList = pl;
        isLoading = false;
      });
    });
  }

  Future<void> datetimeListenerInit() async {
    Duration interval = Duration(seconds: 5);
    Stream<DateTime> stream = Stream<DateTime>.periodic(interval, (i) {
      currentTime = currentTime.add(Duration(seconds: 5));
      return currentTime;
    });
    datetimeSubscription = stream.listen((data) {
      formattedDate = formatter.format(data);
      // print(formattedDate);
      _fire.getLoginDate().then((String date) {
        // print(date);
        if (formattedDate != date) {
          /// check whether user has logined in
          if (parkNames.contains(placeName)) {
            exp++;
            _fire.updateLoginDate(formattedDate);
            _fire.updateExp(exp);
          }
        }
      });
      // print(exp);
    });
  }

  void locationListenerInit() {
    locationSubscription =
        location.onLocationChanged.listen((LocationData cLoc) async {
      /// cLoc contains the lat and long of the
      /// current user's position in real time,
      /// so we're holding on to it
      currentLocation = cLoc;
      if (isSwitched) {
        point = GeoPoint(currentLocation.latitude, currentLocation.longitude);
        List<geocod.Placemark> placemarks =
            await geocod.placemarkFromCoordinates(
                currentLocation.latitude, currentLocation.longitude);
        placeName = placemarks[0].name;
        print("${placemarks[0]}");
        _fire.updateLocationInfo(point);
      } else {
        point = null;
        _fire.updateLocationInfo(point);
      }

/*       if (_controller != null) {
        _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(cLoc.latitude, cLoc.longitude), zoom: 11.0)));
      } */
    });
  }

  /// get currentLocation
  void setInitialLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    /// set the initial location by pulling the user's
    /// current location from the location's getLocation()
    currentLocation = await location.getLocation();
    if (isSwitched) {
      point = GeoPoint(currentLocation.latitude, currentLocation.longitude);
      _fire.updateLocationInfo(point);
    } else {
      point = null;
      _fire.updateLocationInfo(point);
    }
  }

  /// convert svg into bitmap image for marker icon
  Future<BitmapDescriptor> getBitmapDescriptorFromSVGAsset(
    BuildContext context,
    String svgAssetLink,
    Size size,
  ) async {
    String svgString = await DefaultAssetBundle.of(context).loadString(
      svgAssetLink,
    );
    final drawableRoot = await svg.fromSvgString(
      svgString,
      'debug: $svgAssetLink',
    );
    final ratio = ui.window.devicePixelRatio.ceil();
    final width = size.width.ceil() * ratio;
    final height = size.height.ceil() * ratio;
    final picture = drawableRoot.toPicture(
      size: Size(
        width.toDouble(),
        height.toDouble(),
      ),
    );
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uInt8List = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(uInt8List);
  }

  ///set image into bitmap icon
  void _setMarkerIcon() async {
    BitmapDescriptor icon = await getBitmapDescriptorFromSVGAsset(
        context, 'assets/dog-park.svg', const Size(56, 56));
    setState(() {
      _markerIcon = icon;
    });
  }

  void mapCreated(controller) {
    _controller = controller;
    setState(() {
      parkList.forEach((element) {
        markerList.add(Marker(
          markerId: MarkerId(element.uid),
          draggable: false,
          onTap: () {
            _showMaterialDialog(element);
          },
          icon: _markerIcon,
          position: element.locationCoords,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: 11.0,
        // tilt: CAMERA_TILT,
        // bearing: CAMERA_BEARING,
        target: _initialPosition);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          zoom: 11.0,
          // tilt: CAMERA_TILT,
          // bearing: CAMERA_BEARING,
          target: LatLng(48.4040243,-123.3498126));
    }
    return isLoading
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            body: Stack(children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  myLocationEnabled: true,
                  initialCameraPosition: initialCameraPosition,
                  markers: Set.from(markerList),
                  onMapCreated: mapCreated,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled:false,
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 15.0),
                child: Stack(children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                          if (isSwitched) {
                            point = GeoPoint(currentLocation.latitude,
                                currentLocation.longitude);
                            _fire.updateLocationInfo(point);
                            setState(() => _scaffoldKey.currentState
                                .showSnackBar(new SnackBar(
                                    duration: const Duration(seconds: 2),
                                    content: new Text(
                                        "Location ON! Your location is shown to others"))));
                          } else {
                            point = null;
                            _fire.updateLocationInfo(point);
                            setState(() => _scaffoldKey.currentState
                                .showSnackBar(new SnackBar(
                                    duration: const Duration(seconds: 2),
                                    content: new Text(
                                        "Location OFF! Your location is hidden from others"))));
                          }
                        });
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.person),
                      iconSize: 45,
                      color: Colors.grey[600],
                      onPressed: () {
                        locationSubscription.cancel();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return ProfileScreen(
                                firebaseFirestore: FirebaseFirestore.instance,
                                auth: FirebaseAuth.instance);
                          }),
                        ).then((value) {
                          locationListenerInit();
                        });
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: IconButton(
                      icon: Icon(Icons.message),
                      iconSize: 45,
                      color: Colors.grey[600],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return ChatListScreen();
                          }),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(Icons.group_add_outlined),
                      iconSize: 45,
                      color: Colors.grey[600],
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return FriendListScreen();
                        }));
                      },
                    ),
                  ),
                ]),
              ),
            ]),
            floatingActionButton: FloatingActionButton(
              heroTag: "but1",
              onPressed: () {
                _controller.animateCamera(
                    CameraUpdate.newCameraPosition(CameraPosition(
                  target: LatLng(
                      currentLocation.latitude, currentLocation.longitude),
                  zoom: 11.0,
                )));
              },
              child: Icon(Icons.location_on),
              backgroundColor: Color(0x44000000),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }

  _showMaterialDialog(park) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        content: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            // closed button
            Positioned(
              right: -38.0,
              top: -38.0,
              child: InkResponse(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.yellow[700],
                  radius: 15,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  park.parkName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                InkWell(
                  child: Text(
                    park.address,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                SvgPicture.asset(
                  parkImage,
                  semanticsLabel: 'Park Image',
                  placeholderBuilder: (BuildContext context) => Container(
                      padding: const EdgeInsets.all(30.0),
                      child: const CircularProgressIndicator()),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ParkMap(park: park)),
                      );
                    },
                    child: Text(
                      'Enter',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

/*   moveCamera(element) {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: element.locationCoords,
        zoom: 14.0,
        bearing: 45.0,
        tilt: 45.0)));
  } */
}
