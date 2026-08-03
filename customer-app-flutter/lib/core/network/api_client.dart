import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../storage/token_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';

/// Ilova bo'ylab ishlatiladigan yagona Dio nusxasi.
/// - Har bir so'rovga avtomatik `Authorization: Bearer <token>` qo'shadi
/// - 401 xatoligida refresh token orqali qayta urinadi
/// - Xatoliklarni foydalanuvchiga tushunarli `ApiException`ga o'giradi
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final retryResponse = await _retry(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          handler.next(error);
        },
      ),
    );

    assert(() {
      _dio.interceptors.add(PrettyDioLogger(requestBody: true, responseBody: true));
      return true;
    }());
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;
  bool _isRefreshing = false;

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) {
    final options = Options(method: requestOptions.method, headers: requestOptions.headers);
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<bool> _tryRefreshToken() async {
    _isRefreshing = true;
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
      final accessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;
      await TokenStorage.saveTokens(accessToken: accessToken, refreshToken: newRefreshToken);
      return true;
    } catch (_) {
      await TokenStorage.clear();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? query, required T Function(dynamic) parse}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return parse(res.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> post<T>(String path, {dynamic data, required T Function(dynamic) parse}) async {
    try {
      final res = await _dio.post(path, data: data);
      return parse(res.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> patch<T>(String path, {dynamic data, required T Function(dynamic) parse}) async {
    try {
      final res = await _dio.patch(path, data: data);
      return parse(res.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final data = e.response?.data;
    String message = "Server bilan bog'lanishda xatolik yuz berdi";
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      message = m is List ? m.join(', ') : m.toString();
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = "Internet aloqasi sekin yoki uzilgan";
    } else if (e.type == DioExceptionType.connectionError) {
      message = "Serverga ulanib bo'lmadi. Internetni tekshiring";
    }
    return ApiException(message, statusCode: e.response?.statusCode);
  }
}
