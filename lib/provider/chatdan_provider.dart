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

  void clear() {
    _accessToken = null;
    _userInfo = null;
    tokenInvalid = true;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('access_token');
      notifyListeners();
    });
  }
}
