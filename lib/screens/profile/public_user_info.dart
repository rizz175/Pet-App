import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/dog_object.dart';
import 'package:pet_app/services/storage.dart';
import 'package:pet_app/shared/my_flutter_app_icons.dart';

// Constant Text font Style used in widget
var _textStyle1 = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 30,
);
var _textStyle2 = TextStyle(
  color: Colors.blue[50],
  fontSize: 12,
);

// Set the male and female label present the gender
Icon _maleIcon = Icon(MyFlutterApp.male, size: 12, color: Colors.blue[100]);
Icon _femaleIcon = Icon(MyFlutterApp.female, size: 12, color: Colors.red[100]);

// The page is show the public infomation of the profile whether the owner and the visitor can see it
class PublicUsrInfo extends StatefulWidget {
  final Dog dog;
  // For the page, we need the specific dog object for that user
  PublicUsrInfo(this.dog);

  @override
  _PublicUsrInfoState createState() => _PublicUsrInfoState();
}

class _PublicUsrInfoState extends State<PublicUsrInfo> {
  bool isLoading = true;
  String avatarUrl;
  var _storage = StorageServices();

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image of the dog
              FutureBuilder(
                  future: widget.dog == null
                      ? null
                      : _storage.getAvatarUrl(uid: widget.dog.uid),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: snapshot.hasData
                          ? NetworkImage(snapshot.data)
                          : AssetImage('images/icon.png'),
                    );
                  }),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name and gender icon
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 160.0,
                        ),
                        child: AutoSizeText(
                          widget.dog?.name ?? 'loading...',
                          style: _textStyle1,
                          maxLines: 2,
                        ),
                      ),
                      widget.dog?.gender == null
                          ? SizedBox()
                          : (widget.dog.gender == 'Male'
                              ? _maleIcon
                              : _femaleIcon)
                    ],
                  ),

                  // age and breed
                  Row(
                    children: [
                      Text(
                        widget.dog?.age ?? '',
                        style: _textStyle2,
                      ),
                      SizedBox(width: 12),
                      Text(
                        widget.dog?.breedAsString ?? '',
                        style: _textStyle2,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // weight
                  (widget.dog?.weight ?? 'null') == null.toString()
                      ? SizedBox()
                      : Row(
                          children: [
                            Icon(
                              MyFlutterApp.weight_hanging,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              widget.dog.weight + ' kg',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
