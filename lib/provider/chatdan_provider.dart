import 'package:chatdan_frontend/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatDanProvider extends ChangeNotifier {
  String? _accessToken;

  User? _userInfo;

  User? get userInfo => _userInfo;

  set userInfo(User? value) {
    _userInfo = value;
    notifyListeners();
  }

  bool get isUserInitialized => _accessToken != null && userInfo != null;

  bool get isUserLoggedIn => _accessToken != null;

  String? get accessToken => _accessToken;

  bool tokenInvalid = false;

  set accessToken(String? value) {
    _accessToken = value;
    tokenInvalid = false;
    notifyListeners();
  }

  // debug only
  Future<void> setAccessToken(String value) async {
    _accessToken = value;
    tokenInvalid = false;
    var preferences = await SharedPreferences.getInstance();
    await preferences.setString('access_token', value);
  }

  Future<void> clear() async {
    _accessToken = null;
    _userInfo = null;
    tokenInvalid = true;
    var preferences = await SharedPreferences.getInstance();
    await preferences.remove('access_token');
    notifyListeners();
  }
}
