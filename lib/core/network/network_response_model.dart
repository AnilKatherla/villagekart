class NetworkResponseModel {
  NetworkResponseModel({
    required this.errorMessage,
    required this.data,
    this.isSuccess = false,
  });
  final String? errorMessage;
  final dynamic data;
  final bool isSuccess;
}
