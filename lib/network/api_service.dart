import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_response.dart';
import 'package:ventalink_mobile/utils/common_utils.dart';

// ignore: constant_identifier_names
enum RequestType { GET, POST, PUT, PATCH, DELETE }

class Api {
  final dio = createDio();
  Api._internal();
  static final _singleton = Api._internal();
  factory Api() => _singleton;
  static Dio createDio() {
    var dio = Dio(
      BaseOptions(
        baseUrl: GlobalEndpoints.appBackend,
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );
    dio.interceptors.addAll({Logging(dio), ErrorInterceptors(dio)});
    return dio;
  }

  Future<NetworkResponse?> apiCall(String url, Map<String, dynamic>? queryParameters, dynamic body, RequestType requestType, {String? authToken}) async {
    late Response result;
    try {
      Map<String, String> headers = await getAuthHeader(overrideToken: authToken);
      Options options = Options(headers: headers);
      switch (requestType) {
        case RequestType.GET:
          result = await dio.get(url, queryParameters: queryParameters, options: options);
          break;
        case RequestType.POST:
          log("Printing data :${GlobalEndpoints.appBackend} $url $body");
          result = await dio.post(url, data: body, options: options);
          break;
        case RequestType.DELETE:
          result = await dio.delete(url, data: queryParameters, options: options);
          break;
        case RequestType.PUT:
          result = await dio.put(url, data: body, options: options);
          break;
        case RequestType.PATCH:
          result = await dio.patch(url, data: body, options: options);
          break;
      }

      // If no error occurred and response is successful
      if (result.statusCode != null && result.statusCode! >= 200 && result.statusCode! <= 300) {
        return NetworkResponse.success(result.data);
      } else {
        return NetworkResponse.error(message: result.data['message'].toString(), statusCode: result.statusCode);
      }
    } on DioException catch (error) {
      // If a Dio exception occurs, return the error message
      return NetworkResponse.error(message: error.message ?? "An error occurred.");
    } catch (error) {
      // If any other type of error occurs, return a generic error
      return NetworkResponse.error(message: error.toString());
    }
  }
}

// class AuthInterceptor extends Interceptor {
//   final Dio dio;
//   AuthInterceptor(this.dio);
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     var accessToken = await TokenRepository().getAccessToken();
//     if (accessToken != null) {
//       var expiration = await TokenRepository().getAccessTokenRemainingTime();
//       if (expiration.inSeconds < 60) {
//         dio.interceptors.requestLock.lock();
//         // Call the refresh endpoint to get a new token
//         await UserService().refresh().then((response) async {
//           await TokenRepository().persistAccessToken(response.accessToken);
//           accessToken = response.accessToken;
//         }).catchError((error, stackTrace) {
//           handler.reject(error, true);
//         }).whenComplete(() => dio.interceptors.requestLock.unlock());
//       }
//       options.headers['Authorization'] = 'Bearer $accessToken';
//     }
//     return handler.next(options);
//   }
// }
class ErrorInterceptors extends Interceptor {
  final Dio dio;

  ErrorInterceptors(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 400:
        throw BadRequestException(err.requestOptions);
      case 401:
        throw UnauthorizedException(err.requestOptions);
      case 404:
        throw NotFoundException(err.requestOptions);
      case 409:
        throw ConflictException(err.requestOptions);
      case 500:
        throw InternalServerErrorException(err.requestOptions);
    }
  }
}

class BadRequestException extends DioException {
  BadRequestException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    return 'Invalid request';
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    return 'Unknown error occurred, please try again later.';
  }
}

class ConflictException extends DioException {
  ConflictException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    return 'Conflict occurred';
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    return 'Access denied';
  }
}

class NotFoundException extends DioException {
  NotFoundException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    return 'The requested information could not be found';
  }
}

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    return 'No internet connection detected, please try again.';
  }
}

class TimeOutException extends DioException {
  TimeOutException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    return 'The connection has timed out, please try again.';
  }
}

class Logging extends Interceptor {
  final Dio dio;
  Logging(this.dio);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
      'ERROR[${err.response?.statusCode}] '
      'TYPE: ${err.type} '
      'MSG: ${err.message} '
      'URL: ${err.requestOptions.baseUrl}${err.requestOptions.path}',
    );
    return super.onError(err, handler);
  }
}

Future<Map<String, String>> getAuthHeader({String? overrideToken}) async {
  CommonUtils commonUtils = CommonUtils();
  final token = overrideToken?.trim().isNotEmpty == true ? overrideToken!.trim() : (await commonUtils.getToken())?.trim();

  return {'Content-type': 'application/json', 'Accept': 'application/json', 'Authorization': token != null && token.isNotEmpty ? 'Bearer $token' : ''};
}
