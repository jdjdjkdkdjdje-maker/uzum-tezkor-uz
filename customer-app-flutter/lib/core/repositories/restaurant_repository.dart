import '../models/restaurant.dart';
import '../network/api_client.dart';

class RestaurantRepository {
  final _client = ApiClient.instance;

  Future<List<Restaurant>> findAll({
    String? search,
    double? latitude,
    double? longitude,
    double radiusKm = 10,
  }) {
    return _client.get<List<Restaurant>>(
      '/restaurants',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'radiusKm': radiusKm,
        'limit': 50,
      },
      parse: (data) => (data['items'] as List<dynamic>)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Restaurant> findOne(String id) {
    return _client.get<Restaurant>('/restaurants/$id', parse: (data) => Restaurant.fromJson(data));
  }
}
