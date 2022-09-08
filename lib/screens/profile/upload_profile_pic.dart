import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_app/services/storage.dart';
import 'package:pet_app/shared/loading.dart';
import 'package:flutter/services.dart' show rootBundle;

class UploadProfile extends StatefulWidget {
  @override
  _UploadProfileState createState() => _UploadProfileState();
}

class _UploadProfileState extends State<UploadProfile> {
  final _key = GlobalKey<ScaffoldState>();

  final _picker = ImagePicker();
  File _image;
  StorageServices _storage = StorageServices();
  String avatarUrl;

  bool isLoading = true;

  ListTile _createTile(
      BuildContext context, String name, IconData icon, Function action) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        action();
      },
    );
  }

  mainBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(context, 'Choose from default avatars',
                  Icons.local_activity, getDefault),
              _createTile(
                  context, 'Take Photo', Icons.camera_alt, _imgFromCamera),
              _createTile(context, 'My Images', Icons.photo_library, getImage),
            ],
          );
        });
  }

  Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/default_avatar/$path');
  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return file;
}


  Future getDefault() async {
    File imagePlaceHolder;
    final path = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayDefaultAvatar(),
        ));
    if (path != null) {
      imagePlaceHolder = await getImageFileFromAssets(path);
    }
    setState(() {
      _image = imagePlaceHolder;
    });
  }

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        print(pickedFile.path);
        _image = File(pickedFile.path);
      }
    });
  }

  Future _imgFromCamera() async {
    XFile image = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      if (image != null) {
        _image = image as File;
      }
    });
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    _storage.getAvatarUrl().then((String url) {
      setState(() {
        avatarUrl = url;
        isLoading = false;
      });
    });

    super.initState();
  }

  Widget _saveButton(bool isEnabled) {
    return isEnabled
        ? RaisedButton(
            color: Colors.yellow[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            onPressed: () async {
              await _storage.uploadProfileImage(_image);
              setState(() {
                _key.currentState
                    .showSnackBar(SnackBar(content: Text('Image Uploaded')));
              });
            },
            child: Text(
              '   save image   ',
              style: TextStyle(color: Colors.white),
            ),
          )
        : RaisedButton(
            disabledColor: Colors.grey,
            onPressed: null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Text('   save image   '),
          );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            key: _key,
            backgroundColor: Colors.blue,
            appBar: AppBar(
              shadowColor: Colors.transparent,
              title: Text('Upload profile image'),
            ),
            body: Column(
              children: [
                SizedBox(height: 20),
                Center(
                  child: FlatButton(
                    // onPressed: getImage,
                    onPressed: () => mainBottomSheet(context),
                    child: CircleAvatar(
                        radius: 150,
                        backgroundImage: _image == null
                            ? NetworkImage(avatarUrl)
                            : FileImage(_image)),
                  ),
                ),
                SizedBox(height: 20),
                _saveButton(_image != null)
              ],
            ),
          );
  }
}

class DisplayDefaultAvatar extends StatefulWidget {
  DisplayDefaultAvatar({Key key}) : super(key: key);
  @override
  _DisplayDefaultAvatar createState() => _DisplayDefaultAvatar();
}

class _DisplayDefaultAvatar extends State<DisplayDefaultAvatar> {
  Directory appDocDir;
  String appDocPath;

  @override
  void initState() {
    getPath();
    super.initState();
  }

  getPath() async {
    appDocDir = await getApplicationDocumentsDirectory();
    appDocPath = appDocDir.path;
    print(appDocPath);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Default Avatar"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
          child: GridView.extent(
              maxCrossAxisExtent: 130,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              children: <Widget>[
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset1.png'),
              child: Image.asset("assets/default_avatar/Asset1.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset2.png'),
              child: Image.asset("assets/default_avatar/Asset2.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset3.png'),
              child: Image.asset("assets/default_avatar/Asset3.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset4.png'),
              child: Image.asset("assets/default_avatar/Asset4.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset5.png'),
              child: Image.asset("assets/default_avatar/Asset5.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset6.png'),
              child: Image.asset("assets/default_avatar/Asset6.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset7.png'),
              child: Image.asset("assets/default_avatar/Asset7.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset8.png'),
              child: Image.asset("assets/default_avatar/Asset8.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset9.png'),
              child: Image.asset("assets/default_avatar/Asset9.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset10.png'),
              child: Image.asset("assets/default_avatar/Asset10.png"),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pop(context, 'Asset11.png'),
              child: Image.asset("assets/default_avatar/Asset11.png"),
            ),
          ])),
    );
  }
}
