import 'package:api_request_manager/models/base_dto.dart';
import 'package:http/http.dart';

abstract class ApiErrorHandler {
  Future<BaseDto> handleRequestException({
    required Object error,
    required StackTrace stackTrace,
    required Uri uri,
    required bool doLog,
  });

  Future<BaseDto> handleStatusCodeNotOk({
    required Uri uri,
    required Response response,
    required String? requestBody,
    required bool doLog,
  });
}
