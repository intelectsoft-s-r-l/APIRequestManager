abstract class Logger {
  Future<void> logRequestResult({
    required String endpoint,
    required String action,
    required dynamic dto,
    required String? body,
    required Map<String, dynamic> jsonResult,
    bool? isSuccess,
  });

  Future<void> logToCloud(
      {required String action,
      required String message,
      required String details,
      required bool isError});

  Future<void> logExceptionWithStack(Object exception, StackTrace? stackTrace, String action);

  String getMethodAndClassName({int callDepth});
}
