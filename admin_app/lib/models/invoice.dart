class Invoice {
  final String id;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String paymentStatus;
  final String? paymentMethod;
  final double paidAmount;
  final InvoiceInsurance insurance;
  final String notes;
  final bool sentToPatient;
  final DateTime? sentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentStatus,
    this.paymentMethod,
    required this.paidAmount,
    required this.insurance,
    required this.notes,
    required this.sentToPatient,
    this.sentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      patientEmail: json['patientEmail'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      invoiceDate: DateTime.parse(json['invoiceDate']),
      dueDate: DateTime.parse(json['dueDate']),
      items: (json['items'] as List?)
              ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
      tax: json['tax']?.toDouble() ?? 0.0,
      discount: json['discount']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'],
      paidAmount: json['paidAmount']?.toDouble() ?? 0.0,
      insurance: InvoiceInsurance.fromJson(json['insurance'] ?? {}),
      notes: json['notes'] ?? '',
      sentToPatient: json['sentToPatient'] ?? false,
      sentDate: json['sentDate'] != null ? DateTime.parse(json['sentDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'partial':
        return 'Partial';
      case 'paid':
        return 'Paid';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      default:
        return paymentStatus;
    }
  }

  double get remainingAmount => total - paidAmount;
  bool get isPaid => paymentStatus == 'paid';
  bool get isOverdue => paymentStatus == 'overdue' || (paymentStatus == 'pending' && DateTime.now().isAfter(dueDate));
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;
  final String? category;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.category,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: json['unitPrice']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      category: json['category'],
    );
  }
}

class InvoiceInsurance {
  final String provider;
  final String policyNumber;
  final String claimNumber;
  final double coverageAmount;

  InvoiceInsurance({
    this.provider = '',
    this.policyNumber = '',
    this.claimNumber = '',
    this.coverageAmount = 0.0,
  });

  factory InvoiceInsurance.fromJson(Map<String, dynamic> json) {
    return InvoiceInsurance(
      provider: json['provider'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      claimNumber: json['claimNumber'] ?? '',
      coverageAmount: json['coverageAmount']?.toDouble() ?? 0.0,
    );
  }
}
