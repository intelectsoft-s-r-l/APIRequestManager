import 'package:api_request_manager/models/repository_error.dart';

class BaseDto {
  final RepositoryError? repositoryError;
  final int errorCode;
  final String? errorMessage;

  BaseDto({required this.errorCode, required this.repositoryError, this.errorMessage});

  bool get isError => errorCode != 0;

  bool get isSuccess => !isError;

  factory BaseDto.fromJson(Map<String, dynamic> json, {bool usePascalCase = false}) {
    String errorCodeName = usePascalCase ? 'ErrorCode' : 'errorCode';
    String errorMessageName = usePascalCase ? 'ErrorMessage' : 'errorMessage';
    return BaseDto(
      repositoryError: null,
      errorCode: json[errorCodeName] as int,
      errorMessage: json[errorMessageName] as String?,
    );
  }

  @override
  String toString() {
    return 'BaseDto(errorCode: $errorCode, errorMessage: ${errorMessage ?? "null"}, repositoryError: $repositoryError)';
  }
}
