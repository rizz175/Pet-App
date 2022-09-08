import 'package:flutter/material.dart';

import '../services/auth.dart';

// TODO: redesign loading screen
class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'pet book',
      // theme:
      home: Scaffold(
        body: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child:
                  Image.asset('assets/petme_logo.png', height: 200, width: 200),
            ),
            ElevatedButton(
                child: Text('signOut'),
                onPressed: () async {
                  await AuthServices().signOut();
                })
          ],
        ),
        // backgroundColor: Color.fromRGBO(47, 119, 129, 1.0),
        backgroundColor: Colors.blue[400],
      ),
    );
  }
}
