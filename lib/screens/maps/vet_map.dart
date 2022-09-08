import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/models/vet_model.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:location/location.dart';
import 'package:pet_app/services/database.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/shared/loading.dart';

/// display vet clinics inside the vet map, allow users to select a vet clinic for his/her profile
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Marker> allMarkers = [];
  GoogleMapController _controller;
  BitmapDescriptor _markerIcon;
  PageController _pageController;
  LocationData currentLocation;
  StreamSubscription<LocationData> locationSubscription;
  Location location;
  static LatLng _initialPosition = LatLng(53.5461, -113.4938);
  List<Vet> vetClinics;
  Vet _currentVet;

  ///firebase connection
  Dog dog;
  FireStoreServices _fire;
  String vetName;
  bool isLoading = true;
  int prevPage;
  @override
  void initState() {
    super.initState();
    location = new Location();
    _fire =
        FireStoreServices(FirebaseFirestore.instance, FirebaseAuth.instance);
    firebaseInteraction();

    /// set the initial location
    setInitialLocation();

    /// subscribe to changes in the user's caion
    /// by "listening" to the location's onLocationChanged event
    locationSubscription =
        location.onLocationChanged.listen((LocationData cLoc) {
      /// cLoc contains the lat and long of the
      /// current user's position in real time,
      /// so we're holding on to it
      currentLocation = cLoc;
    });

    /// set custom marker pins
    _setMarkerIcon();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8)
      ..addListener(_onScroll);
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  /// Get the vet infomation in th firestore
  void firebaseInteraction() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    String uid = _auth.currentUser.uid;
    _fire.getUserObj(uid).then((Dog d) {
      dog = d;
      setState(() {});
    });
    _fire.getVetObj().then((List<Vet> vcs) {
      setState(() {
        vetClinics = vcs;
      });
    });
  }

  /// get current location with service permission
  void setInitialLocation() async {
    currentLocation = await location.getLocation();
  }

  ///searchBar added
  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('Choose a Vet'),
        backgroundColor: Color(0x44000000),
        elevation: 0,
        toolbarHeight: 45,
        actions: [searchBar.getSearchAction(context)]);
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
    isLoading = true;
    BitmapDescriptor icon = await getBitmapDescriptorFromSVGAsset(
        context, 'assets/pet-hospital.svg', const Size(100, 80));
    setState(() {
      _markerIcon = icon;
      isLoading = false;
    });
  }

  /// created map function
  void mapCreated(controller) {
    _controller = controller;
    setState(() {
      vetClinics.forEach((element) {
        allMarkers.add(Marker(
            markerId: MarkerId(element.uid),
            draggable: false,
            infoWindow:
                InfoWindow(title: element.clinicName, snippet: element.address),
            icon: _markerIcon,
            position: element.locationCoords));
      });
      _currentVet = vetClinics[0];
    });
  }

  void _onSubmitted(String value) {
    var found = 0;
    for (var i = 0; i < vetClinics.length; i++) {
      if (vetClinics[i].clinicName == value) {
        moveCamera(vetClinics[i]);
        _pageController.animateToPage(i,
            duration: Duration(milliseconds: 300), curve: Curves.linear);
        found = 1;
        _currentVet = vetClinics[i];
        break;
      } else if (vetClinics[i].address == value) {
        moveCamera(vetClinics[i]);
        _pageController.animateToPage(i,
            duration: Duration(milliseconds: 300), curve: Curves.linear);
        found = 1;
        _currentVet = vetClinics[i];
        break;
      }
    }
    if (found == 0) {
      setState(() => _scaffoldKey.currentState
          .showSnackBar(new SnackBar(content: new Text('Vet not found!'))));
    }
  }

  void _onScroll() {
    if (_pageController.page.toInt() != prevPage) {
      prevPage = _pageController.page.toInt();
      moveCamera(vetClinics[prevPage]);
      _currentVet = vetClinics[prevPage];
    }
  }

  _VetClinicList(index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget widget) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page - index;
          value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 150.0,
            width: Curves.easeInOut.transform(value) * 350.0,
            child: widget,
          ),
        );
      },
      child: InkWell(
          onTap: () {
            // moveCamera();
          },
          child: Stack(children: [
            Center(
                child: Container(
                    margin: EdgeInsets.only(bottom: 30.0),
                    height: 150.0,
                    width: 275.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            offset: Offset(0.0, 4.0),
                            blurRadius: 10.0,
                          ),
                        ]),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white),
                        child: Row(children: [
                          Container(
                              height: 120.0,
                              width: 90.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      topLeft: Radius.circular(10.0)),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          vetClinics[index].thumbNail),
                                      fit: BoxFit.cover))),
                          SizedBox(width: 5.0),
                          Flexible(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                  vetClinics[index].clinicName,
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  vetClinics[index].address,
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                FlatButton(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onPressed: () {
                                    openBrowserTab(vetClinics[index]);
                                  },
                                  child: Text(
                                    vetClinics[index].website,
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ]))
                        ]))))
          ])),
    );
  }

  openBrowserTab(vet) async {
    await FlutterWebBrowser.openWebPage(url: "https://" + vet.website + "/");
  }

  _MapScreenState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: _onSubmitted,
        onCleared: () {
          print("cleared");
        },
        onClosed: () {
          setState(() => _scaffoldKey.currentState.showSnackBar(
              new SnackBar(content: new Text('Please Choose a Vet'))));
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
          target: LatLng(currentLocation.latitude, currentLocation.longitude));
    }
    return isLoading
        ? Loading()
        : Scaffold(
            appBar: searchBar.build(context),
            key: _scaffoldKey,
            body: Stack(children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  myLocationEnabled: true,
                  initialCameraPosition: initialCameraPosition,
                  markers: Set.from(allMarkers),
                  onMapCreated: mapCreated,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
              Positioned(
                bottom: 30.0,
                child: Container(
                  height: 200.0,
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: vetClinics.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _VetClinicList(index);
                    },
                  ),
                ),
              )
            ]),
            floatingActionButton: Stack(children: <Widget>[
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  heroTag: "but1",
                  onPressed: () {
                    _controller.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                      target:
                          // _initialPosition,
                          LatLng(currentLocation.latitude,
                              currentLocation.longitude),
                      zoom: 11.0,
                    )));
                  },
                  child: Icon(Icons.location_on),
                  backgroundColor: Color(0x44000000),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton.extended(
                  heroTag: "but2",
                  onPressed: () async {
                    dog.vetName = _currentVet.clinicName;
                    await _fire.updateUserInfo(dog);
                    Navigator.pop(context, true);
                  },
                  icon: Icon(
                    Icons.save,
                    color: Colors.blue[100],
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  label: Text('Save'),
                  backgroundColor: Color(0x44000000),
                ),
              )
            ]));
  }

  // move camera according to geolocation
  moveCamera(element) {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: element.locationCoords,
        zoom: 14.0,
        bearing: 45.0,
        tilt: 45.0)));
  }

  // handle tap on marker
  _handleTap(LatLng tappedPoint) {
    setState(() {
      allMarkers = [];
      allMarkers.add(Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          draggable: true,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onDragEnd: (dragEndPosition) {}));
    });
  }
}
