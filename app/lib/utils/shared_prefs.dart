import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  static Future init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  String get userName => _sharedPrefs?.getString("userName") ?? "";
  String get password => _sharedPrefs?.getString("password") ?? "";
  String get token => _sharedPrefs?.getString("token") ?? "";

  set userName(String value) {
    _sharedPrefs?.setString("userName", value);
  }

  set password(String value) {
    _sharedPrefs?.setString("password", value);
  }

  set token(String value) {
    _sharedPrefs?.setString("token", value);
  }

  void clear() {
    _sharedPrefs?.clear();
  }
}
