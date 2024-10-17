enum RepositoryError {
  success(0),
  internalError(1),
  statusCodeNotOk(2),
  requestTimeout(3),
  socketException(4),
  noInternet(5);

  final int code;

  const RepositoryError(this.code);

  static Map<int, RepositoryError> repositoryErrorsMap = {
    for (var error in RepositoryError.values) error.code: error
  };
}
