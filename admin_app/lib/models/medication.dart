class Medication {
  final String id;
  final String name;
  final String genericName;
  final String category;
  final String description;
  final String manufacturer;
  final List<String> dosageForms;
  final String strength;
  final int stock;
  final int minStockLevel;
  final double price;
  final DateTime? expiryDate;
  final String batchNumber;
  final String storageConditions;
  final List<String> sideEffects;
  final List<String> contraindications;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.name,
    this.genericName = '',
    required this.category,
    this.description = '',
    this.manufacturer = '',
    this.dosageForms = const [],
    this.strength = '',
    required this.stock,
    this.minStockLevel = 10,
    required this.price,
    this.expiryDate,
    this.batchNumber = '',
    this.storageConditions = '',
    this.sideEffects = const [],
    this.contraindications = const [],
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      genericName: json['genericName'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      dosageForms: (json['dosageForms'] as List?)?.map((e) => e.toString()).toList() ?? [],
      strength: json['strength'] ?? '',
      stock: json['stock'] ?? 0,
      minStockLevel: json['minStockLevel'] ?? 10,
      price: json['price']?.toDouble() ?? 0.0,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      batchNumber: json['batchNumber'] ?? '',
      storageConditions: json['storageConditions'] ?? '',
      sideEffects: (json['sideEffects'] as List?)?.map((e) => e.toString()).toList() ?? [],
      contraindications: (json['contraindications'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get categoryDisplay {
    switch (category) {
      case 'fertility':
        return 'Fertility';
      case 'hormone':
        return 'Hormone';
      case 'antibiotic':
        return 'Antibiotic';
      case 'painkiller':
        return 'Painkiller';
      case 'supplement':
        return 'Supplement';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  bool get isLowStock => stock <= minStockLevel;
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return expiryDate!.isBefore(thirtyDaysFromNow) && expiryDate!.isAfter(now);
  }
}
