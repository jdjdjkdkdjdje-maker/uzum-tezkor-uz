import 'package:flutter/foundation.dart';
import '../core/models/user.dart';
import '../core/network/api_exception.dart';
import '../core/repositories/auth_repository.dart';
import '../core/repositories/user_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _authRepository = AuthRepository();
  final _userRepository = UserRepository();

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;
  bool isLoading = false;
  String? errorMessage;

  Future<void> bootstrap() async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (!loggedIn) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      currentUser = await _userRepository.getMe();
      status = AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> sendOtp(String phoneNumber) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.sendOtp(phoneNumber);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp({required String phoneNumber, required String code, String? fullName}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _authRepository.verifyOtp(
        phoneNumber: phoneNumber,
        code: code,
        fullName: fullName,
      );
      currentUser = result.user;
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> socialLogin({required String provider, required String idToken}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _authRepository.socialLogin(provider: provider, idToken: idToken);
      currentUser = result.user;
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    try {
      currentUser = await _userRepository.getMe();
      notifyListeners();
    } catch (_) {
      // sokin xato — profil keyingi urinishda yangilanadi
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
