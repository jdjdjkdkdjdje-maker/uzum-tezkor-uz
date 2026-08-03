import '../models/user.dart';
import '../network/api_client.dart';

class UserRepository {
  final _client = ApiClient.instance;

  Future<AppUser> getMe() {
    return _client.get<AppUser>('/users/me', parse: (data) => AppUser.fromJson(data));
  }

  Future<AppUser> updateMe({String? fullName, String? avatarUrl, String? language}) {
    return _client.patch<AppUser>(
      '/users/me',
      data: {
        if (fullName != null) 'fullName': fullName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (language != null) 'language': language,
      },
      parse: (data) => AppUser.fromJson(data),
    );
  }
}
