class BaseDto {
  final int errorCode;
  final String? errorMessage;

  BaseDto({required this.errorCode, this.errorMessage});

  bool get isError => errorCode != 0;

  bool get isSuccess => !isError;

  factory BaseDto.fromJson(Map<String, dynamic> json, {bool usePascalCase = false}) {
    String errorCodeName = usePascalCase ? 'ErrorCode' : 'errorCode';
    String errorMessageName = usePascalCase ? 'ErrorMessage' : 'errorMessage';
    return BaseDto(
      errorCode: json[errorCodeName] as int,
      errorMessage: json[errorMessageName] as String?,
    );
  }

  @override
  String toString() {
    return 'BaseDto(errorCode: $errorCode, errorMessage: ${errorMessage ?? "null"})';
  }
}
