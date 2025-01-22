import 'package:firebase_auth/firebase_auth.dart';
import 'package:koda/helpers/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> register(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveLoginStatus(isLoggedIn: true);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveLoginStatus(isLoggedIn: true);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _saveLoginStatus(isLoggedIn: false);
  }

  User? getUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> _saveLoginStatus({required bool isLoggedIn}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(KEY_LOGGED_IN, isLoggedIn);
  }
}