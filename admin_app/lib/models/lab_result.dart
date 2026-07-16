class LabResult {
  final String id;
  final String patientId;
  final String patientName;
  final String? doctorId;
  final String? doctorName;
  final String testType;
  final String testCategory;
  final DateTime testDate;
  final DateTime? reportDate;
  final String labName;
  final SingleResult results;
  final List<MultipleResult> multipleResults;
  final List<Attachment> attachments;
  final String? reviewedBy;
  final DateTime? reviewedDate;
  final String? reviewNotes;
  final bool isAbnormal;
  final bool requiresFollowUp;
  final DateTime? followUpDate;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  LabResult({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.doctorId,
    this.doctorName,
    required this.testType,
    required this.testCategory,
    required this.testDate,
    this.reportDate,
    this.labName = '',
    required this.results,
    required this.multipleResults,
    required this.attachments,
    this.reviewedBy,
    this.reviewedDate,
    this.reviewNotes,
    required this.isAbnormal,
    required this.requiresFollowUp,
    this.followUpDate,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      doctorId: json['doctorId']?.toString(),
      doctorName: json['doctorName'],
      testType: json['testType'] ?? '',
      testCategory: json['testCategory'] ?? '',
      testDate: DateTime.parse(json['testDate']),
      reportDate: json['reportDate'] != null ? DateTime.parse(json['reportDate']) : null,
      labName: json['labName'] ?? '',
      results: SingleResult.fromJson(json['results'] ?? {}),
      multipleResults: (json['multipleResults'] as List?)
              ?.map((e) => MultipleResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: (json['attachments'] as List?)
              ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reviewedBy: json['reviewedBy']?.toString(),
      reviewedDate: json['reviewedDate'] != null ? DateTime.parse(json['reviewedDate']) : null,
      reviewNotes: json['reviewNotes'],
      isAbnormal: json['isAbnormal'] ?? false,
      requiresFollowUp: json['requiresFollowUp'] ?? false,
      followUpDate: json['followUpDate'] != null ? DateTime.parse(json['followUpDate']) : null,
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get testCategoryDisplay {
    switch (testCategory) {
      case 'hormone':
        return 'Hormone';
      case 'genetic':
        return 'Genetic';
      case 'infectious':
        return 'Infectious';
      case 'semen':
        return 'Semen Analysis';
      case 'other':
        return 'Other';
      default:
        return testCategory;
    }
  }

  bool get isReviewed => reviewedBy != null;
}

class SingleResult {
  final String? value;
  final String unit;
  final String referenceRange;
  final String status;
  final String notes;

  SingleResult({
    this.value,
    this.unit = '',
    this.referenceRange = '',
    this.status = '',
    this.notes = '',
  });

  factory SingleResult.fromJson(Map<String, dynamic> json) {
    return SingleResult(
      value: json['value']?.toString(),
      unit: json['unit'] ?? '',
      referenceRange: json['referenceRange'] ?? '',
      status: json['status'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class MultipleResult {
  final String parameter;
  final String value;
  final String unit;
  final String referenceRange;
  final String status;

  MultipleResult({
    required this.parameter,
    required this.value,
    this.unit = '',
    this.referenceRange = '',
    this.status = '',
  });

  factory MultipleResult.fromJson(Map<String, dynamic> json) {
    return MultipleResult(
      parameter: json['parameter'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
      referenceRange: json['referenceRange'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class Attachment {
  final String url;
  final String name;
  final DateTime uploadDate;

  Attachment({
    required this.url,
    required this.name,
    required this.uploadDate,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      url: json['url'] ?? '',
      name: json['name'] ?? '',
      uploadDate: DateTime.parse(json['uploadDate']),
    );
  }
}
