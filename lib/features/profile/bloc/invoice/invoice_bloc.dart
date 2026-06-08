// features/profile/bloc/invoice/invoice_bloc.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:villag_kart/features/profile/bloc/invoice/invoice_event.dart';
import 'package:villag_kart/features/profile/bloc/invoice/invoice_state.dart';
import 'package:villag_kart/features/profile/model/invoice_model.dart';
import 'package:villag_kart/features/profile/services/order_service.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  InvoiceBloc() : super(InvoiceInitialState()) {
    on<FetchInvoiceEvent>(_onFetchInvoice);
    on<DownloadInvoiceEvent>(_onDownloadInvoice);
  }

  Future<void> _onFetchInvoice(
    FetchInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceLoadingState(orderId: event.orderId));

    try {
      final invoiceResponse = await OrderService.fetchInvoice(
        orderId: event.orderId,
      );

      emit(InvoiceLoadedState(invoice: invoiceResponse.data.invoice));
    } catch (e) {
      emit(InvoiceErrorState(error: e.toString()));
    }
  }

  Future<void> _onDownloadInvoice(
    DownloadInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceDownloadingState(orderId: event.orderId));

    try {
      // First fetch invoice data
      final invoiceResponse = await OrderService.fetchInvoice(
        orderId: event.orderId,
      );
      
      // Create PDF or HTML content from invoice data
      final invoiceContent = _createInvoiceHtml(invoiceResponse.data.invoice);
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/invoice_${event.orderId}.html';
      final file = File(filePath);
      await file.writeAsString(invoiceContent);

      emit(InvoiceDownloadedState(
        filePath: filePath,
        orderId: event.orderId,
      ));
    } catch (e) {
      emit(InvoiceErrorState(error: e.toString()));
    }
  }

  String _createInvoiceHtml(Invoice invoice) {
    // Create HTML invoice template
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice ${invoice.invoiceNumber}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .invoice-header { text-align: center; margin-bottom: 30px; }
        .invoice-details { display: flex; justify-content: space-between; margin-bottom: 30px; }
        .invoice-items { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        .invoice-items th, .invoice-items td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .invoice-items th { background-color: #f2f2f2; }
        .invoice-total { text-align: right; margin-top: 20px; }
        .total-row { font-weight: bold; font-size: 18px; }
    </style>
</head>
<body>
    <div class="invoice-header">
        <h1>INVOICE</h1>
        <h2>#${invoice.invoiceNumber}</h2>
        <p>Date: ${invoice.invoiceDate.toLocal()}</p>
    </div>
    
    <div class="invoice-details">
        <div class="from">
            <h3>From:</h3>
            <p>${invoice.warehouse.name}</p>
            <p>${invoice.warehouse.address}</p>
            <p>Phone: ${invoice.warehouse.phone ?? 'N/A'}</p>
        </div>
        
        <div class="to">
            <h3>To:</h3>
            <p>${invoice.customer.name ?? 'Customer'}</p>
            <p>${invoice.shippingAddress.line1}, ${invoice.shippingAddress.line2}</p>
            <p>${invoice.shippingAddress.city}, ${invoice.shippingAddress.state} ${invoice.shippingAddress.pincode}</p>
            <p>Phone: ${invoice.customer.phone}</p>
        </div>
    </div>
    
    <table class="invoice-items">
        <thead>
            <tr>
                <th>Item</th>
                <th>Quantity</th>
                <th>Unit Price</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
            ${invoice.items.map((item) => '''
            <tr>
                <td>${item.name}</td>
                <td>${item.quantity} ${item.unit}</td>
                <td>₹${item.unitPrice.toStringAsFixed(2)}</td>
                <td>₹${item.totalPrice.toStringAsFixed(2)}</td>
            </tr>
            ''').join('')}
        </tbody>
    </table>
    
    <div class="invoice-total">
        <p>Subtotal: ₹${invoice.summary.subtotal.toStringAsFixed(2)}</p>
        <p>Discount: ₹${invoice.summary.discount.toStringAsFixed(2)}</p>
        <p>Delivery Charge: ₹${invoice.summary.deliveryCharge.toStringAsFixed(2)}</p>
        <p>Tax: ₹${invoice.summary.taxAmount.toStringAsFixed(2)}</p>
        <p class="total-row">Total Amount: ₹${invoice.summary.totalAmount.toStringAsFixed(2)}</p>
    </div>
    
    <div style="margin-top: 40px; text-align: center; color: #666;">
        <p>Thank you for your business!</p>
        <p>VillagKart</p>
    </div>
</body>
</html>
''';
  }
}