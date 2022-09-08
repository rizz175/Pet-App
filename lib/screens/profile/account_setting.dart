import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/screens/profile/passwordChange.dart';
import 'package:pet_app/screens/profile/emailChange.dart';
import 'package:pet_app/screens/profile/LinkSocialMedia.dart';

/// This page is the account setting page to change account info
/// Two link to change email or change password
class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _ListItem(Icons.email, 'Change Email', ChangeEmailScreen()),
            _ListItem(Icons.vpn_key, 'Change Password', ChangePassScreen()),
            _ListItem(Icons.share_rounded, 'Link to Social Media',
                LinkSocialMedia()),
          ],
        ),
      ),
    );
  }
}

/// Public function that the owner will see the edit
/// Vistor will see the addFriend or nothing
class _ListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final StatelessWidget nextPage;

  _ListItem(this.icon, this.text, this.nextPage);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return nextPage;
          }),
        );
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 50,
            color: Colors.blue,
          ),
          SizedBox(width: 15),
          Text(text)
        ],
      ),
    );
  }
}
