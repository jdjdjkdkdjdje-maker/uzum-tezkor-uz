import '../models/address.dart';
import '../network/api_client.dart';

class AddressRepository {
  final _client = ApiClient.instance;

  Future<List<Address>> findAll() {
    return _client.get<List<Address>>(
      '/addresses',
      parse: (data) =>
          (data as List<dynamic>).map((e) => Address.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<Address> create(Address address) {
    return _client.post<Address>(
      '/addresses',
      data: address.toJson(),
      parse: (data) => Address.fromJson(data),
    );
  }

  Future<Address> update(String id, Map<String, dynamic> data) {
    return _client.patch<Address>(
      '/addresses/$id',
      data: data,
      parse: (data) => Address.fromJson(data),
    );
  }

  Future<void> remove(String id) => _client.delete('/addresses/$id');
}
