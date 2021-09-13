import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gitnotify/utils/shared_prefs.dart';

import 'login.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late bool _showLoader;

  //initState
  @override
  void initState() {
    super.initState();
    _showLoader = false;
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
                Colors.black54,
              ],
            ),
          ),
          width: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "You're all set",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                        "You'll be receiving notifications when there is any activity in your github dashboard. You can close the app now. If you want to stop receiving notifications you can logout by tapping the button below!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ))),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.black45),
                      onPressed: () async {
                        SystemNavigator.pop();
                      },
                      child: Text(
                        'Close App',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _showLoader = true;
                        });
                        var url = Uri.parse(
                            'https://gitnotify-backend.azurewebsites.net/logout');
                        await http.post(
                          url,
                          headers: {
                            'Content-Type': 'application/json',
                          },
                          body:
                              json.encode({'userName': SharedPrefs().userName}),
                        );
                        SharedPrefs().clear();
                        setState(() {
                          _showLoader = false;
                        });
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.black87),
                      child: !_showLoader
                          ? Text(
                              'Log Out',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            )
                          : SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                color: Colors.black54,
                              ),
                            ),
                    ),
                  ),
                ),
              ])),
    );
  }
}
