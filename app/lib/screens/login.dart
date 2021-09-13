import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gitnotify/screens/main_screen.dart';
import 'package:gitnotify/utils/shared_prefs.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //username controller
  TextEditingController _usernameController = TextEditingController();
  //password controller
  TextEditingController _passwordController = TextEditingController();

  late bool _showLoader;

  late FirebaseMessaging messaging;

  //initState
  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    _showLoader = false;
  }

  Future<void> _login() async {
    //get username and password
    String username = _usernameController.text;
    String password = _passwordController.text;

    //check if username and password are not empty
    if (username.isEmpty || password.isEmpty) {
      //show error
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.grey[300],
              title: Text('Error'),
              content: Text('Please enter username and password'),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.black87),
                  child: Text(
                    'Ok',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      return;
    } else {
      //save username and password in shared preferences
      setState(() {
        _showLoader = true;
      });
      SharedPrefs().userName = username;
      SharedPrefs().password = password;
      messaging.getToken().then((value) async {
        SharedPrefs().token = value!;
        var url =
            Uri.parse('https://gitnotify-backend.azurewebsites.net/login');
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
              {'userName': username, 'password': password, 'token': value}),
        );
      });
      //delay
      await Future.delayed(Duration(milliseconds: 1000));
      setState(() {
        _showLoader = false;
      });

      //navigate to main screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    }
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
              Colors.black87,
            ],
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(bottom: 40),
                alignment: Alignment.center,
                child: Text("Login to get started",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    )),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: 'UserName',
                      hintText: 'Enter your github userName'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter your secure password'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _login();
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.black54),
                    child: !_showLoader
                        ? Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )
                        : SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 10, right: 10),
                  child: Text(
                    "If you are logging in for the first time enter a password of your choice, your username will be registered automatically. Make sure you do remember your password the next time you log in :)",
                    style: TextStyle(color: Colors.white54, fontSize: 15),
                    textAlign: TextAlign.center,
                  )),
            ]),
      ),
    );
  }
}
