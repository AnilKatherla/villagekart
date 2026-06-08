import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/payment/Service/payment_api_service.dart';
import 'package:villag_kart/features/payment/bloc/paymentevent.dart';
import 'package:villag_kart/features/payment/bloc/paymentstate.dart';
import 'package:villag_kart/features/payment/view/payment_options.dart' hide PaymentState;

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentApiService apiService;

  PaymentBloc(this.apiService) : super(PaymentInitial()) {
    // on<PaymentUpdateTransactionStatusEvent>(_updatePaymentStatus);
    on<VerifyPaymentEvent>(_onVerifyPayment);
  }

  
  Future<void> _onVerifyPayment(
  VerifyPaymentEvent event,
  Emitter<PaymentState> emit,
) async {
  emit(PaymentLoadingState());

  try {
    await apiService.verifyPayment(
      orderId: event.orderId,
      razorpayPaymentId: event.razorpaypaymentId,
      razorpayOrderId: event.razorpayOrderId,
      razorpaySignature: event.razorpaySignature,
    );

    emit(PaymentSuccessState());
  } catch (e) {
    emit(PaymentErrorState(e.toString()));
  }
}
}
