import 'package:freezed_annotation/freezed_annotation.dart';
part 'api_response.freezed.dart';

@freezed
class NetworkResponse with _$NetworkResponse {
  const factory NetworkResponse.success(Map<String, dynamic> data) = Ok;

  const factory NetworkResponse.error({required String message, int? statusCode}) = ERROR;

  const factory NetworkResponse.loading(String message) = LOADING;
}
