import '../models/banner.dart';
import '../network/api_client.dart';

class BannerRepository {
  final _client = ApiClient.instance;

  Future<List<BannerModel>> findActive() {
    return _client.get<List<BannerModel>>(
      '/banners',
      parse: (data) => (data as List<dynamic>)
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
