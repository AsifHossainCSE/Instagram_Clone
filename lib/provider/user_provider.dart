import 'package:flutter/widgets.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  // ✅ SAFE getter (NO CRASH)
  User? get getUser => _user;

  // Optional helper
  bool get hasUser => _user != null;

  Future<void> refreshUser() async {
    try {
      User user = await _authMethods.getUserDetails();
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Failed to load user: $e");
    }
  }
}