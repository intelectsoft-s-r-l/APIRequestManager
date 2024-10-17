# API Request Manager

A Dart package for managing API requests with error handling, logging, and flexible configuration. This package simplifies the process of making HTTP requests while providing a structured way to handle responses and errors.

## Features

- Easy HTTP request management (GET, POST, DELETE).
- Built-in error handling.
- Customizable logging.
- Support for different response types using Data Transfer Objects (DTOs).

## Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  api_request_manager:
    git:
      url: https://github.com/intelectsoft-s-r-l/APIRequestManager
      ref: main
```
Then, run:

```bash
flutter pub get 
```

## Usage

### Import the Package
```dart
import 'package:api_request_manager/api_request_manager.dart';
import 'package:api_request_manager/api_error_handler.dart';
import 'package:api_request_manager/logger.dart';
import 'package:api_request_manager/base_dto.dart';

// Initialize the Logger and Error Handler
// You need to create instances that implement Logger and ApiErrorHandler classes before using the ApiRequestManager.

final logger = MyLogger(); // Implement your logging logic by implementing Logger, or by using cloud_logger package
final errorHandler = MyApiErrorHandler(); // Implement your error handling logic, by implementing ApiErrorHandler, or use NetworkAndApiErrorHandler

// Create an instance of ApiRequestManager
// You can create an instance of ApiRequestManager with the required dependencies:
final apiRequestManager = ApiRequestManager(
  logger: logger,
  errorHandler: errorHandler,
  timeoutDuration: Duration(seconds: 15), // Optional, default is 20 seconds
);
```
### Making Requests

**GET Request**
```dart
Future<void> fetchData() async {
  final uri = Uri.parse('https://api.example.com/data');

  final response = await apiRequestManager.get<MyDataDto>(
    uri: uri,
    fromJson: (json) => MyDataDto.fromJson(json),
  );
  // Use the response
}
```

**POST Request**
```dart
Future<void> sendData(MyDataDto data) async {
  final uri = Uri.parse('https://api.example.com/data');
  
  final MyDataDto response = await apiRequestManager.post<MyDataDto>(
    uri: uri,
    body: jsonEncode(data.toJson()),
    fromJson: (json) => MyDataDto.fromJson(json),
  );
  // Use the response
}
```

**DELETE Request**
```dart
Future<void> deleteData(String id) async {
  final uri = Uri.parse('https://api.example.com/data/$id');
  
  final MyDataDto response = await apiRequestManager.delete<MyDataDto>(
    uri: uri,
    fromJson: (json) => MyDataDto.fromJson(json),
  );
  // Use the response
}
``` 
**Data Transfer Object (DTO)**
Create a DTO class extending BaseDto for your API responses:

```dart
class MyDataDto extends BaseDto {
  final String id;
  final String name;

  MyDataDto({required this.id, required this.name, required super.errorCode, super.errorMessage});

  factory MyDataDto.fromJson(Map<String, dynamic> json) {
    return MyDataDto(
      id: json['id'],
      name: json['name'],
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'name': name,
      'errorCode': errorCode
    };
    if (errorMessage != null) json['errorMessage'] = errorMessage;
    return json;
  }
}
```

### Creating basic authorization header with content type application/json
```dart
Future<void> getHeaders() async {  
  return await apiRequestManager.getHeadersForUsernameAndPassword(
    username: 'deli',
    password: '87sdj1@@',
  );
}
``` 

## Contribution
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.