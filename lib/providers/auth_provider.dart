import 'package:flutter/foundation.dart';
import 'package:bookswap_app/models/user_model.dart';
import 'package:bookswap_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _authService.user.listen((user) {
      _user = user;
      _isLoading = false;
      _error = null;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(email, password, displayName);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}