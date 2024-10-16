library api_request_manager;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_request_manager/http_method.dart';
import 'package:api_request_manager/internet_connection_checker.dart';
import 'package:api_request_manager/logger.dart';
import 'package:api_request_manager/repository_error.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiRequestManager {
  final Duration timeoutDuration;
  final Logger logger;
  final bool usePascalCaseErrorFields;

  ApiRequestManager(
      {required this.logger,
      this.timeoutDuration = const Duration(seconds: 20),
      this.usePascalCaseErrorFields = false});

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

  Future<Map<String, dynamic>> getJsonResponseFor(
      {required Uri uri,
      required String? body,
      required Map<String, String>? headers,
      required HttpMethod httpMethod,
      bool doLog = true}) async {
    try {
      Response response;
      response = await doRequest(httpMethod: httpMethod, uri: uri, headers: headers, body: body);
      if (!isStatusCodeOk(response)) {
        return handleStatusCodeNotOk(uri, response, body, doLog);
      }
      Map<String, dynamic> json = jsonDecode(response.body);
      if (doLog) {
        unawaited(logger.logRequestResult(
            body: body,
            endpoint: uri.path,
            jsonResult: json,
            action: logger.getMethodAndClassName(),
            dto: null));
      }
      return json;
    } on TimeoutException catch (_) {
      return handleTimeoutException(uri, doLog, timeoutDuration);
    } on SocketException catch (exception) {
      return await handleSocketException(uri, exception, doLog);
    } catch (exception, stackTrace) {
      if (doLog) {
        logger.logExceptionWithStack(exception, stackTrace, logger.getMethodAndClassName());
      }
      return getJsonForErrorInfo(RepositoryError.internalError, 'Unknown internal error.');
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

  Future<Map<String, dynamic>> handleSocketException(Uri uri, SocketException e, bool doLog) async {
    if (!await isInternetConnection()) {
      return getJsonForErrorInfo(RepositoryError.noInternet,
          'The request returned SocketException, since there is no internet connection available.');
    }
    if (doLog) {
      logger.logToCloud(
          action: logger.getMethodAndClassName(),
          message: '/${uri.path} returned SocketException.',
          details: 'The exception: ${e.toString()}',
          isError: true);
    }
    return getJsonForErrorInfo(
        RepositoryError.socketException, 'The request returned SocketException.');
  }

  Map<String, dynamic> handleTimeoutException(Uri uri, bool doLog, Duration timeoutDuration) {
    if (doLog) {
      logger.logToCloud(
        action: logger.getMethodAndClassName(),
        message: '/${uri.path} did not respond in $timeoutDuration seconds.',
        details: '',
        isError: true,
      );
    }
    return getJsonForErrorInfo(RepositoryError.requestTimeout,
        'The request did not complete in ${timeoutDuration.inSeconds} seconds.');
  }

  Map<String, dynamic> handleStatusCodeNotOk(
      Uri uri, http.Response response, String? body, bool doLog) {
    if (doLog) {
      logger.logToCloud(
          action: logger.getMethodAndClassName(callDepth: 1),
          message: 'Called ${uri.path} with failure',
          details: 'Request returned status code ${response.statusCode}. I sent body: $body.',
          isError: true);
    }
    return getJsonForErrorInfo(RepositoryError.statusCodeNotOk,
        'The request returned status code ${response.statusCode}.');
  }

  Map<String, dynamic> getJsonForErrorInfo(RepositoryError repositoryError, String message) {
    if (usePascalCaseErrorFields) {
      return {'ErrorCode': repositoryError.code, 'ErrorMessage': message};
    }
    return {'errorCode': repositoryError.code, 'errorMessage': message};
  }
}
