abstract class PaymentEvent {}

class PaymentUpdateTransactionStatusEvent extends PaymentEvent {
  final String orderId;
  final String transactionId;
  final String razorpayOrderId;
  final String razorpaySignature;

  PaymentUpdateTransactionStatusEvent({
    required this.orderId,
    required this.transactionId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });
}
class VerifyPaymentEvent extends PaymentEvent {
  final String orderId;
  final String razorpaypaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;

  VerifyPaymentEvent({
    required this.orderId,
    required this.razorpaypaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });
}