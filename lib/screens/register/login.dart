import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_app/shared/constants.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../maps/world_map.dart';

/// This page is allow user to login with email and password
class LoginScreen extends StatefulWidget {
  final Function toggleView;

  /// This page is required the statement of the bool variable in auth_wrap
  LoginScreen(this.toggleView);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.blue[300],
        body: BlocListener<AuthBloc, AuthState>(listener: (context, state) {
      if (state is Authenticated) {
        // Navigating to the dashboard screen if the user is authenticated
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => WorldMap()));
      }
      if (state is AuthError) {
        // Showing the error message if the user has entered invalid credentials
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(state.error),
                  Icon(Icons.error, color: Colors.white)
                ],
              ),
              // duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
      }
      if (state is Loading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Logging In...'),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
      }
    }, child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is UnAuthenticated) {
          return SigninBody();
        }
        return Container();
      },
    )));
  }

  Widget SigninBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 120.0, horizontal: 50.0),
      child: Column(
        children: [
          Image.asset(
            'assets/petme.png',
            height: 190.0,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 20),
          SigninForm(),

          /// Change to register if have no account
          TextButton(
            child: Text(
              'Don\'t have an account? Sign up here.',
              style: TextStyle(color: Colors.pink),
            ),
            onPressed: () => widget.toggleView(),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _authenticateWithGoogle(context);
                },
                icon: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1200px-Google_%22G%22_Logo.svg.png",
                  height: 30,
                  width: 30,
                ),
              ),
              IconButton(
                onPressed: () {
                  _authenticateWithFacebook(context);
                },
                icon: Image.asset(
                  "assets/f_logo.png",
                  height: 30,
                  width: 30,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget SigninForm() {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              decoration: textInputDecoration.copyWith(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                return value != null && !EmailValidator.validate(value)
                    ? 'Please enter a valid email'
                    : null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.text,
              controller: _passwordController,
              obscureText: true,
              decoration: textInputDecoration.copyWith(
                labelText: 'Password',
                prefixIcon: Icon(Icons.vpn_key),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                return value != null && value.length < 6
                    ? "Please enter min. 6 characters"
                    : null;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0), // <-- Radius
                  ),
                ),
                onPressed: () {
                  _authenticateWithEmailAndPassword(context);
                },
                child: const Text('Sign In'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _authenticateWithEmailAndPassword(context) {
    if (_formKey.currentState.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        SignInRequested(_emailController.text, _passwordController.text),
      );
    }
  }

  void _authenticateWithGoogle(context) {
    BlocProvider.of<AuthBloc>(context).add(
      GoogleSignInRequested(),
    );
  }

  void _authenticateWithFacebook(context) {
    BlocProvider.of<AuthBloc>(context).add(
      FacebookSignInRequested(),
    );
  }
}
