import 'package:flutter/material.dart';
import 'package:pet_app/screens/register/login.dart';
import 'package:pet_app/screens/register/register.dart';

/// wrap up login and register screen,
/// user can toggle between those 2 screens
class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isShowLogin = true;
  void toggleView() {
    setState(() => isShowLogin = !isShowLogin);
  }

  @override
  Widget build(BuildContext context) {
    return isShowLogin ? LoginScreen(toggleView) : RegisterScreen(toggleView);
  }
}
