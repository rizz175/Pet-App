import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/screens/maps/world_map.dart';
import 'package:pet_app/screens/register/auth_wrapper.dart';
import 'package:provider/provider.dart';

/// show home screen if the user has logged in
/// show register/login screen otherwise
class HomeScreenWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      return AuthWrapper();
    } else {
      return WorldMap();
    }
  }
}
