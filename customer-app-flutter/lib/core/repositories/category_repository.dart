import '../models/product.dart';
import '../network/api_client.dart';

class CategoryRepository {
  final _client = ApiClient.instance;

  Future<List<ProductCategory>> findAll({String? restaurantId}) {
    return _client.get<List<ProductCategory>>(
      '/categories',
      query: restaurantId != null ? {'restaurantId': restaurantId} : null,
      parse: (data) => (data as List<dynamic>)
          .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
