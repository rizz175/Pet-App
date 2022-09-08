import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/models/store_model.dart';
import 'package:pet_app/screens/profile/other_profile.dart';
import 'package:location/location.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pet_app/models/park_model.dart';
import 'package:pet_app/services/database.dart';
import 'package:pet_app/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// display parks inside the park map, allow users to see other users and stores inside the park
class ParkMap extends StatefulWidget {
  final Park park;
  ParkMap({Key key, @required this.park}) : super(key: key);

  @override
  _ParkMapState createState() => _ParkMapState();
}

class _ParkMapState extends State<ParkMap> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Marker> markerList = [];
  GoogleMapController mapController;
  BitmapDescriptor _markerIcon;
  BitmapDescriptor _markerStoreIcon;
  BitmapDescriptor _markerVetIcon;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData currentLocation;
  Location location;
  String _nightMapStyle;
  String _lightMapStyle;
  Color _styleColor = Colors.red[400];
  Color _typeColor = Colors.white12;
  bool _nightMode = false;
  bool _globalMode = false;
  IconData _styleIcon = Icons.wb_sunny_outlined;
  bool isLoading = true;
  GeoPoint point;
  FireStoreServices _fire;
  List<Dog> dogsList;
  List<Store> storeList = [];
  var _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    location = new Location();
    _setMarkerIcon();
    _fire =
        FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
    firebaseInteraction();

    /// set custom marker pins
    /// set the initial location
    setInitialLocation();
    rootBundle.loadString('assets/light_mapStyle.json').then((string) {
      _lightMapStyle = string;
    });
    rootBundle.loadString('assets/night_mapStyle.json').then((string) {
      _nightMapStyle = string;
    });
  }

  /// Get the dog infomation in the firestore
  void firebaseInteraction() {
    widget.park.storeList.forEach((uid) {
      if (uid != "") {
        _fire.getStoreObj(uid).then((Store s) {
          setState(() {
            storeList.add(s);
          });
        });
      }
    });
    _fire.getAllUserObj().then((List<Dog> dl) {
      setState(() {
        dogsList = dl;
      });
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
  }

  /// convert svg into bitmap image for marker icon
  Future<BitmapDescriptor> getBitmapDescriptorFromSVGAsset(
      BuildContext context, String svgAssetLink, Size size) async {
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
    isLoading = true;
    BitmapDescriptor icon = await getBitmapDescriptorFromSVGAsset(
      context,
      'assets/pet-profile.svg',
      const Size(56, 56),
    );
    BitmapDescriptor iconStore = await getBitmapDescriptorFromSVGAsset(
      context,
      'assets/pet-shop.svg',
      const Size(100, 80),
    );
    BitmapDescriptor iconVet = await getBitmapDescriptorFromSVGAsset(
      context,
      'assets/pet-hospital.svg',
      const Size(100, 80),
    );
    setState(() {
      _markerIcon = icon;
      _markerStoreIcon = iconStore;
      _markerVetIcon = iconVet;
    });
    isLoading = false;
  }

  void mapCreated(controller) {
    mapController = controller;
    mapController.setMapStyle(_lightMapStyle);
    setState(() {
      dogsList.forEach((element) {
        markerList.add(Marker(
          markerId: MarkerId(element.uid),
          draggable: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherProScreen(uid: element.uid),
              ),
            );
          },
          icon: _markerIcon,
          position: element.location,
        ));
      });
      storeList.forEach((store) {
        markerList.add(Marker(
          markerId: MarkerId(store.uid),
          draggable: false,
          onTap: () {
            openBrowserTab(store.website);
          },
          icon: _markerStoreIcon,
          position: store.location,
        ));
      });
      markerList.add(Marker(
        markerId: MarkerId(widget.park.uid),
        draggable: false,
        onTap: () {
          // print(widget.park.vetWebsite);
          openBrowserTab(widget.park.vetWebsite);
        },
        icon: _markerVetIcon,
        position: widget.park.locationCoords,
      ));
    });
  }

  openBrowserTab(website) async {
    await FlutterWebBrowser.openWebPage(url: "https://" + website + "/");
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            // appBar: searchBar.build(context),
            key: _scaffoldKey,
            body: Stack(children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: widget.park.locationCoords,
                      zoom: widget.park.cameraList[0],
                      bearing: widget.park.cameraList[1],
                      tilt: widget.park.cameraList[2]),
                  // onTap: _handelTap,
                  markers: Set.from(markerList),
                  mapType: this._mapType,
                  onMapCreated: mapCreated,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ]),
            floatingActionButton: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton(
                    heroTag: "but1",
                    onPressed: () {
                      mapController.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              target: widget.park.locationCoords,
                              zoom: widget.park.cameraList[0],
                              bearing: widget.park.cameraList[1],
                              tilt: widget.park.cameraList[2])));
                    },
                    child: Icon(Icons.crop_free_sharp),
                    backgroundColor: Color(0x44000000),
                  ),
                ),
                Container(
                  child: SpeedDial(
                    // both default to 16
                    // marginRight: 30,
                    animatedIcon: AnimatedIcons.menu_close,
                    animatedIconTheme: IconThemeData(size: 22.0),

                    /// this is ignored if animatedIcon is non null
                    visible: true,

                    /// If true user is forced to close dial manually
                    /// by tapping main button and overlay is not rendered.
                    closeManually: false,
                    curve: Curves.bounceIn,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.5,
                    onOpen: () => print('OPENING DIAL'),
                    onClose: () => print('DIAL CLOSED'),
                    backgroundColor: Color(0x44000000),
                    foregroundColor: Colors.white,
                    elevation: 8.0,
                    shape: CircleBorder(),
                    children: [
                      SpeedDialChild(
                        child: Icon(_styleIcon),
                        backgroundColor: _styleColor,
                        labelStyle: TextStyle(fontSize: 18.0),
                        onTap: () {
                          setState(() {
                            if (_nightMode) {
                              _nightMode = !_nightMode;
                              _styleIcon = Icons.wb_sunny_outlined;
                              _styleColor = Colors.red[400];
                              mapController.setMapStyle(_lightMapStyle);
                            } else {
                              _nightMode = !_nightMode;
                              _styleIcon = Icons.nights_stay_outlined;
                              _styleColor = Colors.indigo[700];
                              mapController.setMapStyle(_nightMapStyle);
                            }
                          });
                        },
                      ),
                      SpeedDialChild(
                        child: Icon(Icons.satellite_outlined,
                            color: Colors.white60),
                        backgroundColor: _typeColor,
                        labelStyle: TextStyle(fontSize: 18.0),
                        onTap: () {
                          setState(() {
                            if (_globalMode) {
                              _globalMode = !_globalMode;
                              _typeColor = Colors.white12;
                              this._mapType = MapType.normal;
                            } else {
                              _globalMode = !_globalMode;
                              _typeColor = Colors.indigo[600];
                              this._mapType = MapType.satellite;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
