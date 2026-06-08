// features/profile/bloc/invoice/invoice_state.dart

import 'package:villag_kart/features/profile/model/invoice_model.dart';

abstract class InvoiceState {}

class InvoiceInitialState extends InvoiceState {}

class InvoiceLoadingState extends InvoiceState {
  final String orderId;

  InvoiceLoadingState({required this.orderId});
}

class InvoiceLoadedState extends InvoiceState {
  final Invoice invoice;

  InvoiceLoadedState({required this.invoice});
}

class InvoiceDownloadingState extends InvoiceState {
  final String orderId;

  InvoiceDownloadingState({required this.orderId});
}

class InvoiceDownloadedState extends InvoiceState {
  final String filePath;
  final String orderId;

  InvoiceDownloadedState({required this.filePath, required this.orderId});
}

class InvoiceErrorState extends InvoiceState {
  final String error;

  InvoiceErrorState({required this.error});
}