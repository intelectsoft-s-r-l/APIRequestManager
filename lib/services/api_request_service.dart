library api_request_manager;

import 'dart:async';
import 'dart:convert';

import 'package:api_request_manager/constants.dart';
import 'package:api_request_manager/models/base_dto.dart';
import 'package:api_request_manager/interfaces/api_error_handler.dart';
import 'package:api_request_manager/models/http_method.dart';
import 'package:api_request_manager/interfaces/logger.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiRequestService {
  final Logger? logger;
  final ApiErrorHandler errorHandler;
  final Duration timeoutDuration;

  ApiRequestService(
      {required this.logger, required this.errorHandler, this.timeoutDuration = defaultTimeout});

  Map<String, String> getHeadersForUsernameAndPassword(
      {required String? username, required String? password}) {
    Map<String, String> result = <String, String>{
      'Content-type': 'application/json',
    };
    if (username == null && password == null) {
      return result;
    }
    String basicAuth = 'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    return <String, String>{'authorization': basicAuth, 'Content-Type': 'application/json'};
  }

  Future<T> getResponseFor<T extends BaseDto>(
      {required Uri uri,
      required String? body,
      required Map<String, String>? headers,
      required HttpMethod httpMethod,
      required T Function(Map<String, dynamic>) fromJson,
      bool doLog = true}) async {
    try {
      Response response =
          await doRequest(httpMethod: httpMethod, uri: uri, headers: headers, body: body);
      if (!isStatusCodeOk(response)) {
        return errorHandler.handleStatusCodeNotOk(
            uri: uri, response: response, requestBody: body, doLog: doLog) as T;
      }
      Map<String, dynamic> json = jsonDecode(response.body);
      T dto = fromJson(json);
      if (doLog) {
        unawaited(logger?.logRequestResult(
            body: body,
            endpoint: uri.path,
            jsonResult: json,
            action: logger!.getMethodAndClassName(),
            dto: dto));
      }
      return dto;
    } catch (error, stackTrace) {
      return errorHandler.handleRequestException(
          error: error, stackTrace: stackTrace, uri: uri, doLog: doLog) as T;
    }
  }

  Future<http.Response> doRequest(
      {required HttpMethod httpMethod,
      required Uri uri,
      required Map<String, String>? headers,
      required String? body}) async {
    switch (httpMethod) {
      case HttpMethod.get:
        return await http.get(uri, headers: headers).timeout(timeoutDuration);
      case HttpMethod.post:
        return await http.post(uri, headers: headers, body: body).timeout(timeoutDuration);
      case HttpMethod.delete:
        return await http.delete(uri, headers: headers, body: body).timeout(timeoutDuration);
    }
  }

  bool isStatusCodeOk(http.Response response) => [200, 204].contains(response.statusCode);
}
