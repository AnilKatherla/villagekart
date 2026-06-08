class DeliveryFaqResponse {
  final bool status;
  final String response;
  final List<DeliveryFaq> data;


  DeliveryFaqResponse({
    required this.status,
    required this.response,
    required this.data
  });

  factory DeliveryFaqResponse.fromJson(Map<String, dynamic>json){
    return DeliveryFaqResponse(
      status: json['status'] ?? false,
       response: json['response'] ?? '', 
       data:(json['data'] as List)
       .map((e)=>DeliveryFaq.fromJson(e))
       .toList()
        );
  }
}


class DeliveryFaq {
  final int id;
  final String question;
  final String answer;

  DeliveryFaq({
    required this.id,
    required this.question,
    required this.answer
  });
  factory DeliveryFaq.fromJson(Map<String , dynamic>json){
    return DeliveryFaq(
      id: json['id'] ?? 0, 
      question: json['question'] ?? '', 
      answer: json ['answer'] ?? '');
  }
}
