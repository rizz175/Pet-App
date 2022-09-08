import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_app/screens/profile/profile_edit.dart';
import 'package:pet_app/screens/profile/account_setting.dart';
import 'package:pet_app/screens/profile/upload_profile_pic.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../register/auth_wrapper.dart';

// This page is connect to the edit page only for the owner
class ProfileSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UnAuthenticated) {
            // Navigate to the sign in screen when the user Signs Out
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => AuthWrapper()),
              (route) => false,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _ListItem(
                  Icons.account_balance, 'Account Setting', AccountSetting()),
              _ListItem(Icons.date_range, 'Dog profile', EditProfileScreen()),
              _ListItem(Icons.face_retouching_natural, 'Upload profile picture',
                  UploadProfile()),
              // Sign out button
              GestureDetector(
                onTap: () {
                  // Signing out the user
                  context.read<AuthBloc>().add(SignOutRequested());
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      size: 50,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 15),
                    Text('Signout')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Public function that the owner will see the edit
// Vistor will see the addFriend or nothing
class _ListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final StatefulWidget nextPage;

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
