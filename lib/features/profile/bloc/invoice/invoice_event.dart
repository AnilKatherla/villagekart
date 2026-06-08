// features/profile/bloc/invoice/invoice_event.dart
import 'package:villag_kart/features/profile/model/invoice_model.dart';

abstract class InvoiceEvent {}

class FetchInvoiceEvent extends InvoiceEvent {
  final String orderId;

  FetchInvoiceEvent({required this.orderId});
}

class DownloadInvoiceEvent extends InvoiceEvent {
  final String orderId;

  DownloadInvoiceEvent({required this.orderId});
}

class ViewInvoiceEvent extends InvoiceEvent {
  final Invoice invoice;

  ViewInvoiceEvent({required this.invoice});
}