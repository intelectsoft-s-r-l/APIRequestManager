import 'dart:async';
import 'dart:io';

import 'package:api_request_manager/constants.dart';
import 'package:api_request_manager/interfaces/api_error_handler.dart';
import 'package:api_request_manager/models/base_dto.dart';
import 'package:api_request_manager/services/internet_connection_checker.dart';
import 'package:api_request_manager/interfaces/logger.dart';
import 'package:api_request_manager/models/repository_error.dart';
import 'package:http/http.dart';

class NetworkAndApiErrorHandler implements ApiErrorHandler {
  final Duration timeoutDuration;
  final Logger? logger;

  NetworkAndApiErrorHandler({this.logger, this.timeoutDuration = defaultTimeout});

  @override
  Future<BaseDto> handleRequestException(
      {required Object error,
      required StackTrace stackTrace,
      required Uri uri,
      required bool doLog}) async {
    if (error is TimeoutException) {
      return handleTimeoutException(uri, doLog, timeoutDuration);
    } else if (error is SocketException) {
      return await handleSocketException(uri, error, doLog);
    } else {
      logger?.logExceptionWithStack(error, stackTrace, logger!.getMethodAndClassName());
      return getJsonForErrorInfo(RepositoryError.internalError, 'Unknown internal error.');
    }
  }

  @override
  Future<BaseDto> handleStatusCodeNotOk({
    required Uri uri,
    required Response response,
    required String? requestBody,
    required bool doLog,
  }) async {
    if (doLog) {
      logger?.logToCloud(
          action: logger!.getMethodAndClassName(callDepth: 1),
          message: 'Called ${uri.path} with failure',
          details:
              'Request returned status code ${response.statusCode}. I sent body: $requestBody.',
          isError: true);
    }
    return getJsonForErrorInfo(RepositoryError.statusCodeNotOk,
        'The request returned status code ${response.statusCode}.');
  }

  Future<BaseDto> handleSocketException(Uri uri, SocketException e, bool doLog) async {
    if (!await isInternetConnection()) {
      return getJsonForErrorInfo(RepositoryError.noInternet,
          'The request returned SocketException, since there is no internet connection available.');
    }
    if (doLog) {
      logger?.logToCloud(
          action: logger!.getMethodAndClassName(),
          message: '/${uri.path} returned SocketException.',
          details: 'The exception: ${e.toString()}',
          isError: true);
    }
    return getJsonForErrorInfo(
        RepositoryError.socketException, 'The request returned SocketException.');
  }

  BaseDto handleTimeoutException(Uri uri, bool doLog, Duration timeoutDuration) {
    if (doLog) {
      logger?.logToCloud(
        action: logger!.getMethodAndClassName(),
        message: '/${uri.path} did not respond in $timeoutDuration seconds.',
        details: '',
        isError: true,
      );
    }
    return getJsonForErrorInfo(RepositoryError.requestTimeout,
        'The request did not complete in ${timeoutDuration.inSeconds} seconds.');
  }

  BaseDto getJsonForErrorInfo(RepositoryError repositoryError, String message) {
    return BaseDto(errorCode: repositoryError.code, errorMessage: message);
  }
}
