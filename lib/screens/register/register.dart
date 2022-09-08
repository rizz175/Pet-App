import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_app/shared/constants.dart';
import 'package:intl/intl.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../maps/world_map.dart';

/// The name text field function that contain the name text
class NameFieldValidator {
  static String validate(String val) {
    return val.isEmpty ? 'Enter a name' : null;
  }
}

/// The email text field function that contain the email text
class EmailFieldValidator {
  static String validate(String val) {
    return val.isEmpty ? 'Enter an email' : null;
  }
}

/// The password text field function that contain the password text
class PasswordFieldValidator {
  static String validate(String val) {
    return val.isEmpty ? 'Enter an password' : null;
  }
}

/// This page is allowed user register a new account
class RegisterScreen extends StatefulWidget {
  final Function toggleView;

  /// This page is required the statement of the bool variable in auth_wrap
  RegisterScreen(this.toggleView);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String errorMsg;

  DateTime _dateTime;
  String _breed = 'Labrador Retriever';
  DateTime _currentTime = DateTime.now();
  String _currentDate;

  @override
  void initState() {
    errorMsg = '';
    _currentDate = DateFormat('yyyy-MM-dd').format(_currentTime);

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigating to the dashboard screen if the user is authenticated
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => WorldMap(),
              ),
            );
          }
          if (state is AuthError) {
            // Displaying the error message if the user is not authenticated
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is Loading) {
            // Displaying the loading indicator while the user is signing up
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UnAuthenticated) {
            return SignUpBody();
          }
          return Container();
        },
      ),
    );
  }

  Widget SignUpBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 80.0, horizontal: 50.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Create your account',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            /// Enter a name
            TextFormField(
              keyboardType: TextInputType.text,
              controller: _nameController,
              decoration: textInputDecoration.copyWith(
                  labelText: 'Name', prefixIcon: Icon(Icons.pets)),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (val) => NameFieldValidator.validate(val),
            ),
            const SizedBox(height: 10),

            /// Enter a email
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

            /// Enter a password
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
              height: 10,
            ),

            /// Enter the password second time
            TextFormField(
              decoration: textInputDecoration.copyWith(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.vpn_key)),
              validator: (val) => val == _passwordController.text
                  ? null
                  : 'Passwords don\'t match',
              obscureText: true,
            ),
            SizedBox(height: 10),

            /// Choose the breed of dog

            DropdownButton(
              hint: Text('Choose a breed',
                  style: TextStyle(color: Colors.grey[500])),
              isExpanded: true,
              value: _breed,
              style: TextStyle(color: Colors.grey[500], fontSize: 18),
              icon: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.arrow_downward)),
              onChanged: (String newValue) {
                setState(() {
                  _breed = newValue;
                });
              },
              underline: Container(
                height: 2,
                color: Colors.grey[500],
              ),
              dropdownColor: Colors.white,
              items: <String>[
                'Labrador Retriever',
                'Mixed',
                'German Shepard',
                'Shih Tzu',
                'Golden Retriver',
                'Chihuahua',
                'Pomeranian',
                'Yorkshire Terrier',
                'Labradoodle',
                'Dorder Collie',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
              height: 10,
            ),
            // Choose the birthday of dog
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                color: Colors.white,
                child: Text(
                  _dateTime == null
                      ? 'Pick dog\'s birthday'
                      : DateFormat('yyyy-MM-dd').format(_dateTime),
                  style: TextStyle(
                      color:
                          _dateTime == null ? Colors.grey[500] : Colors.black,
                      fontSize: 15),
                ),
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: _dateTime == null ? _currentTime : _dateTime,
                    firstDate: DateTime(2000),
                    lastDate: _currentTime,
                  ).then((date) {
                    setState(() {
                      _dateTime = date;
                    });
                  });
                },
              ),
            ),
            errorMsg == ''
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errorMsg,
                      style: TextStyle(color: Colors.pink),
                    ),
                  ),

            // Sign up the account
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
                  if (_breed == null) {
                    setState(() {
                      errorMsg = 'please choose a bread';
                    });
                    return;
                  }
                  if (_dateTime == null) {
                    setState(() {
                      errorMsg = 'please provide the birthday of your pet';
                    });
                    return;
                  }
                  _createAccountWithEmailAndPassword(context);
                },
                child: const Text('Sign up'),
              ),
            ),

            // Change to login page
            TextButton(
              child: Text(
                'Already have an account? Login here.',
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
      ),
    );
  }

  void _createAccountWithEmailAndPassword(BuildContext context) {
    if (_formKey.currentState.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        SignUpRequested(_emailController.text, _passwordController.text,
            _nameController.text, _breed, _dateTime, _currentDate),
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
