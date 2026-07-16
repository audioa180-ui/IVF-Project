class Patient {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String bloodType;
  final String address;
  final EmergencyContact emergencyContact;
  final Partner partner;
  final MedicalHistory medicalHistory;
  final FertilityProfile fertilityProfile;
  final List<TreatmentHistory> treatmentHistory;
  final ActiveCycle? activeCycle;
  final List<Document> documents;
  final Insurance insurance;
  final Preferences preferences;
  final String status;
  final bool profileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone = '',
    this.dateOfBirth,
    this.bloodType = '',
    this.address = '',
    required this.emergencyContact,
    required this.partner,
    required this.medicalHistory,
    required this.fertilityProfile,
    required this.treatmentHistory,
    this.activeCycle,
    required this.documents,
    required this.insurance,
    required this.preferences,
    required this.status,
    required this.profileComplete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      bloodType: json['bloodType'] ?? '',
      address: json['address'] ?? '',
      emergencyContact: EmergencyContact.fromJson(json['emergencyContact'] ?? {}),
      partner: Partner.fromJson(json['partner'] ?? {}),
      medicalHistory: MedicalHistory.fromJson(json['medicalHistory'] ?? {}),
      fertilityProfile: FertilityProfile.fromJson(json['fertilityProfile'] ?? {}),
      treatmentHistory: (json['treatmentHistory'] as List?)
              ?.map((e) => TreatmentHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeCycle: json['activeCycle'] != null ? ActiveCycle.fromJson(json['activeCycle']) : null,
      documents: (json['documents'] as List?)
              ?.map((e) => Document.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      insurance: Insurance.fromJson(json['insurance'] ?? {}),
      preferences: Preferences.fromJson(json['preferences'] ?? {}),
      status: json['status'] ?? 'active',
      profileComplete: json['profileComplete'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'archived':
        return 'Archived';
      default:
        return status;
    }
  }

  bool get isActive => status == 'active';
  bool get hasActiveCycle => activeCycle != null;
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    this.name = '',
    this.phone = '',
    this.relationship = '',
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }
}

class Partner {
  final String name;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;

  Partner({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.dateOfBirth,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
    );
  }
}

class MedicalHistory {
  final List<String> previousTreatments;
  final List<String> allergies;
  final List<String> medications;
  final List<String> chronicConditions;

  MedicalHistory({
    this.previousTreatments = const [],
    this.allergies = const [],
    this.medications = const [],
    this.chronicConditions = const [],
  });

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
      previousTreatments: (json['previousTreatments'] as List?)?.map((e) => e.toString()).toList() ?? [],
      allergies: (json['allergies'] as List?)?.map((e) => e.toString()).toList() ?? [],
      medications: (json['medications'] as List?)?.map((e) => e.toString()).toList() ?? [],
      chronicConditions: (json['chronicConditions'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class FertilityProfile {
  final double? amhLevel;
  final int? afcCount;
  final double? fshLevel;
  final double? lhLevel;
  final double? estradiolLevel;
  final DateTime? lastUpdated;

  FertilityProfile({
    this.amhLevel,
    this.afcCount,
    this.fshLevel,
    this.lhLevel,
    this.estradiolLevel,
    this.lastUpdated,
  });

  factory FertilityProfile.fromJson(Map<String, dynamic> json) {
    return FertilityProfile(
      amhLevel: json['amhLevel']?.toDouble(),
      afcCount: json['afcCount']?.toInt(),
      fshLevel: json['fshLevel']?.toDouble(),
      lhLevel: json['lhLevel']?.toDouble(),
      estradiolLevel: json['estradiolLevel']?.toDouble(),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
    );
  }
}

class TreatmentHistory {
  final String type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String outcome;
  final String notes;

  TreatmentHistory({
    required this.type,
    this.startDate,
    this.endDate,
    required this.outcome,
    this.notes = '',
  });

  factory TreatmentHistory.fromJson(Map<String, dynamic> json) {
    return TreatmentHistory(
      type: json['type'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      outcome: json['outcome'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class ActiveCycle {
  final String cycleId;
  final String protocol;
  final DateTime startDate;
  final int currentDay;
  final String status;
  final List<CycleMedication> medications;

  ActiveCycle({
    required this.cycleId,
    required this.protocol,
    required this.startDate,
    required this.currentDay,
    required this.status,
    required this.medications,
  });

  factory ActiveCycle.fromJson(Map<String, dynamic> json) {
    return ActiveCycle(
      cycleId: json['cycleId'] ?? '',
      protocol: json['protocol'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      currentDay: json['currentDay'] ?? 1,
      status: json['status'] ?? '',
      medications: (json['medications'] as List?)
              ?.map((e) => CycleMedication.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CycleMedication {
  final String name;
  final String dosage;
  final String frequency;
  final DateTime? startDate;
  final DateTime? endDate;

  CycleMedication({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.startDate,
    this.endDate,
  });

  factory CycleMedication.fromJson(Map<String, dynamic> json) {
    return CycleMedication(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

class Document {
  final String type;
  final String url;
  final String name;
  final DateTime uploadDate;

  Document({
    required this.type,
    required this.url,
    required this.name,
    required this.uploadDate,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      name: json['name'] ?? '',
      uploadDate: DateTime.parse(json['uploadDate']),
    );
  }
}

class Insurance {
  final String provider;
  final String policyNumber;
  final String coverageDetails;

  Insurance({
    this.provider = '',
    this.policyNumber = '',
    this.coverageDetails = '',
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      provider: json['provider'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      coverageDetails: json['coverageDetails'] ?? '',
    );
  }
}

class Preferences {
  final String? preferredDoctor;
  final String preferredClinic;
  final String communicationMethod;

  Preferences({
    this.preferredDoctor,
    this.preferredClinic = '',
    this.communicationMethod = 'email',
  });

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      preferredDoctor: json['preferredDoctor']?.toString(),
      preferredClinic: json['preferredClinic'] ?? '',
      communicationMethod: json['communicationMethod'] ?? 'email',
    );
  }
}
