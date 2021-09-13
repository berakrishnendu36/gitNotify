import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gitnotify/screens/login.dart';
import 'package:gitnotify/screens/main_screen.dart';
import 'package:gitnotify/utils/shared_prefs.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Duration _end = Duration(milliseconds: 2000);
  Duration _animationDuration = Duration(milliseconds: 2200);
  late Animation curve;

  //initState
  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    curve = Tween<double>(begin: 4, end: 40).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutBack));
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.forward();

    Timer(_end, () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SharedPrefs().password != "" ? MainScreen() : Login()));
    });
  }

  //dispose
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: <Color>[
              Colors.white,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Git Notify',
                style: TextStyle(
                  fontSize: curve.value,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
