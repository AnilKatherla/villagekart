// ============================================================================
// MODELS
// ============================================================================

class SuggestionResponse {
  final bool status;
  final String response;
  final SuggestionData? data;

  SuggestionResponse({
    required this.status,
    required this.response,
    this.data,
  });

  factory SuggestionResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawResponse = json['response'];

    return SuggestionResponse(
      status: json['status'] == true,
      response: rawResponse is String
          ? rawResponse
          : rawResponse is Map<String, dynamic>
              ? rawResponse['message']?.toString() ??
                  rawResponse['msg']?.toString() ??
                  'Suggestion submitted successfully'
              : 'Suggestion submitted successfully',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SuggestionData.fromJson(json['data'])
          : null,
    );
  }
}

class SuggestionData {
  final String id;
  final String suggestion;
  final String roleName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SuggestionData({
    required this.id,
    required this.suggestion,
    required this.roleName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SuggestionData.fromJson(Map<String, dynamic> json) {
    return SuggestionData(
      id: json['id']?.toString() ?? '',
      suggestion: json['suggestion']?.toString() ?? '',
      roleName: json['roleName']?.toString() ?? 'USER',
      isActive: json['isActive'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
