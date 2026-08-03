import '../models/product.dart';
import '../network/api_client.dart';

class ProductRepository {
  final _client = ApiClient.instance;

  Future<List<Product>> findByRestaurant(String restaurantId) {
    return _client.get<List<Product>>(
      '/products/restaurant/$restaurantId',
      parse: (data) => (data as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Product> findOne(String id) {
    return _client.get<Product>('/products/$id', parse: (data) => Product.fromJson(data));
  }

  Future<List<Product>> findPopular({int limit = 10}) {
    return _client.get<List<Product>>(
      '/products/popular',
      query: {'limit': limit},
      parse: (data) => (data as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<Product>> search(String query) {
    return _client.get<List<Product>>(
      '/products/search',
      query: {'q': query},
      parse: (data) => (data as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
