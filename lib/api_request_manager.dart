import 'package:api_request_manager/constants.dart';
import 'package:api_request_manager/interfaces/api_error_handler.dart';
import 'package:api_request_manager/services/api_request_service.dart';
import 'package:api_request_manager/models/base_dto.dart';
import 'package:api_request_manager/models/http_method.dart';
import 'package:api_request_manager/interfaces/logger.dart';

class ApiRequestManager {
  final ApiRequestService _manager;

  ApiRequestManager({
    required Logger? logger,
    required ApiErrorHandler errorHandler,
    timeoutDuration = defaultTimeout,
  }) : _manager = ApiRequestService(
          logger: logger,
          errorHandler: errorHandler,
          timeoutDuration: timeoutDuration,
        );

  Map<String, String> getHeadersForUsernameAndPassword(
          {required String? username, required String? password}) =>
      ApiRequestService.getHeadersForUsernameAndPassword(username: username, password: password);

  Future<T> get<T extends BaseDto>(
      {required Uri uri,
      required T Function(Map<String, dynamic>) fromJson,
      bool doLog = true,
      Map<String, String>? headers}) {
    return _manager.getResponseFor(
        uri: uri,
        headers: headers,
        body: null,
        httpMethod: HttpMethod.get,
        fromJson: fromJson,
        doLog: _manager.logger != null && doLog);
  }

  Future<T> post<T extends BaseDto>({
    required Uri uri,
    required T Function(Map<String, dynamic>) fromJson,
    String? body,
    bool doLog = true,
    Map<String, String>? headers,
  }) {
    return _manager.getResponseFor(
        uri: uri,
        headers: headers,
        body: body,
        httpMethod: HttpMethod.post,
        fromJson: fromJson,
        doLog: _manager.logger != null && doLog);
  }

  Future<T> delete<T extends BaseDto>({
    required Uri uri,
    required T Function(Map<String, dynamic>) fromJson,
    String? body,
    bool doLog = true,
    Map<String, String>? headers,
  }) {
    return _manager.getResponseFor(
        uri: uri,
        headers: headers,
        body: body,
        httpMethod: HttpMethod.delete,
        fromJson: fromJson,
        doLog: _manager.logger != null && doLog);
  }
}
