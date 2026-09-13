class ApiResponse {
  final int rensponseCode;
  final dynamic responseData;
  final bool isSuccess;
  final String? errorMessage;

  ApiResponse({
    required this.rensponseCode,
    required this.responseData,
    required this.isSuccess,
    this.errorMessage,
  });
}
