import '../models/user.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final AppUser user;

  AuthResult({required this.accessToken, required this.refreshToken, required this.user});
}

class AuthRepository {
  final _client = ApiClient.instance;

  Future<void> sendOtp(String phoneNumber) {
    return _client.post<void>(
      '/auth/otp/send',
      data: {'phoneNumber': phoneNumber},
      parse: (_) {},
    );
  }

  Future<AuthResult> verifyOtp({
    required String phoneNumber,
    required String code,
    String? fullName,
  }) async {
    final result = await _client.post<AuthResult>(
      '/auth/otp/verify',
      data: {
        'phoneNumber': phoneNumber,
        'code': code,
        if (fullName != null) 'fullName': fullName,
      },
      parse: (data) => AuthResult(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
      ),
    );
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    return result;
  }

  Future<AuthResult> socialLogin({required String provider, required String idToken}) async {
    final result = await _client.post<AuthResult>(
      '/auth/social-login',
      data: {'provider': provider, 'idToken': idToken},
      parse: (data) => AuthResult(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
      ),
    );
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    return result;
  }

  Future<void> logout() => TokenStorage.clear();

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccessToken();
    return token != null;
  }
}
