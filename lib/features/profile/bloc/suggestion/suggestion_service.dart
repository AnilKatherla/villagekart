// ============================================================================
// SERVICE
// ============================================================================

import 'package:dio/dio.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../../core/network/network_service.dart';
import '../../model/suggestion_model.dart';

class SuggestionService {
  
 static final NetworkService _networkService = ServiceLocator.networkService;

  static Future<SuggestionResponse> submitSuggestion({
    required String suggestion,
    required String roleName,
  }) async {
    try {
    
  const String createEndpoint = 'suggestion';

      final Map<String, dynamic> payload = 
      {
        'suggestion': suggestion,
        'roleName': roleName,
      };

      final Response response = await _networkService.post(
        createEndpoint,
        data: payload,
      );


      return SuggestionResponse.fromJson(response.data);

      // Mock API response for demo
      // await Future.delayed(const Duration(seconds: 1));
      
      // final mockResponse = {
      //   "status": true,
      //   "response": "Suggestion submitted successfully",
      //   "data": {
      //     "id": "123e4567-e89b-12d3-a456-426614174000",
      //     "suggestion": suggestion,
      //     "roleName": roleName,
      //     "isActive": true,
      //     "createdAt": DateTime.now().toIso8601String(),
      //     "updatedAt": DateTime.now().toIso8601String(),
      //   }
      // };
      
      // return SuggestionResponse.fromJson(mockResponse);
    } catch (e) {
      throw Exception('Failed to submit suggestion: $e');
    }
  }
}