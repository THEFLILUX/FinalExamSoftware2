import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _preferences;

  static bool _isDarkMode = false;
  static String _userId = '';
  static String _userName = '';
  static String _userEmail = '';
  static String _userPublicKey = '';
  static String _userPrivateKey = '';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Theme local storage
  static bool get isDarkMode {
    return _preferences.getBool('isDarkMode') ?? _isDarkMode;
  }

  static set isDarkMode(bool value) {
    _isDarkMode = value;
    _preferences.setBool('isDarkMode', value);
  }

  // User id
  static String get userId {
    return _preferences.getString('userId') ?? _userId;
  }

  static set userId(String value) {
    _userId = value;
    _preferences.setString('userId', value);
  }

  // User name
  static String get userName {
    return _preferences.getString('userName') ?? _userName;
  }

  static set userName(String value) {
    _userName = value;
    _preferences.setString('userName', value);
  }

  // User email
  static String get userEmail {
    return _preferences.getString('userEmail') ?? _userEmail;
  }

  static set userEmail(String value) {
    _userEmail = value;
    _preferences.setString('userEmail', value);
  }

  // User publicKey
  static String get userPublicKey {
    return _preferences.getString('userPublicKey') ?? _userPublicKey;
  }

  static set userPublicKey(String value) {
    _userPublicKey = value;
    _preferences.setString('userPublicKey', value);
  }

  // User privateKey
  static String get userPrivateKey {
    return _preferences.getString('userPrivateKey') ?? _userPrivateKey;
  }

  static set userPrivateKey(String value) {
    _userPrivateKey = value;
    _preferences.setString('userPrivateKey', value);
  }
}
