// features/profile/model/invoice_model.dart
class InvoiceResponse {
  final bool status;
  final String response;
  final InvoiceData data;

  InvoiceResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: InvoiceData.fromJson(json['data'] ?? {}),
    );
  }
}

class InvoiceData {
  final Invoice invoice;

  InvoiceData({required this.invoice});

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invoice: Invoice.fromJson(json['invoice'] ?? {}),
    );
  }
}

class Invoice {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final InvoiceOrder order;
  final CustomerInfo customer;
  final ShippingAddress shippingAddress;
  final WarehouseInfo warehouse;
  final List<InvoiceItem> items;
  final InvoiceSummary summary;
  final PaymentDetails payment;

  Invoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.order,
    required this.customer,
    required this.shippingAddress,
    required this.warehouse,
    required this.items,
    required this.summary,
    required this.payment,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceNumber: json['invoiceNumber'] ?? '',
      invoiceDate: DateTime.parse(json['invoiceDate'] ?? DateTime.now().toIso8601String()),
      order: InvoiceOrder.fromJson(json['order'] ?? {}),
      customer: CustomerInfo.fromJson(json['customer'] ?? {}),
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] ?? {}),
      warehouse: WarehouseInfo.fromJson(json['warehouse'] ?? {}),
      items: (json['items'] as List?)
              ?.map((e) => InvoiceItem.fromJson(e))
              .toList() ??
          [],
      summary: InvoiceSummary.fromJson(json['summary'] ?? {}),
      payment: PaymentDetails.fromJson(json['payment'] ?? {}),
    );
  }
}

class InvoiceOrder {
  final String id;
  final String orderNumber;
  final String status;
  final DateTime createdAt;

  InvoiceOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.createdAt,
  });

  factory InvoiceOrder.fromJson(Map<String, dynamic> json) {
    return InvoiceOrder(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class CustomerInfo {
  final String? name;
  final String phone;
  final String? email;

  CustomerInfo({
    this.name,
    required this.phone,
    this.email,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'],
    );
  }
}

class ShippingAddress {
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;

  ShippingAddress({
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      line1: json['line1'] ?? '',
      line2: json['line2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

class WarehouseInfo {
  final String name;
  final String address;
  final String? phone;

  WarehouseInfo({
    required this.name,
    required this.address,
    this.phone,
  });

  factory WarehouseInfo.fromJson(Map<String, dynamic> json) {
    return WarehouseInfo(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
    );
  }
}

class InvoiceItem {
  final String name;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  final double taxAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final String? hsnCode;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    required this.taxAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    this.hsnCode,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      igst: (json['igst'] as num?)?.toDouble() ?? 0.0,
      hsnCode: json['hsnCode'],
    );
  }
}

class InvoiceSummary {
  final double subtotal;
  final double discount;
  final double taxableAmount;
  final double taxAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double deliveryCharge;
  final double totalAmount;

  InvoiceSummary({
    required this.subtotal,
    required this.discount,
    required this.taxableAmount,
    required this.taxAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.deliveryCharge,
    required this.totalAmount,
  });

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) {
    return InvoiceSummary(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (json['taxableAmount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      igst: (json['igst'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentDetails {
  final String method;
  final String status;
  final double amount;

  PaymentDetails({
    required this.method,
    required this.status,
    required this.amount,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}