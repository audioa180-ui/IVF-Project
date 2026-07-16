class TreatmentCycle {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String cycleType;
  final String protocol;
  final DateTime startDate;
  final DateTime? endDate;
  final int currentDay;
  final String status;
  final StimulationPhase stimulation;
  final TriggerPhase trigger;
  final OpuPhase opu;
  final EmbryologyPhase embryology;
  final TransferPhase transfer;
  final OutcomePhase outcome;
  final CostInfo costs;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TreatmentCycle({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.cycleType,
    required this.protocol,
    required this.startDate,
    this.endDate,
    required this.currentDay,
    required this.status,
    required this.stimulation,
    required this.trigger,
    required this.opu,
    required this.embryology,
    required this.transfer,
    required this.outcome,
    required this.costs,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentCycle.fromJson(Map<String, dynamic> json) {
    return TreatmentCycle(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      cycleType: json['cycleType'] ?? '',
      protocol: json['protocol'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      currentDay: json['currentDay'] ?? 1,
      status: json['status'] ?? 'planned',
      stimulation: StimulationPhase.fromJson(json['stimulation'] ?? {}),
      trigger: TriggerPhase.fromJson(json['trigger'] ?? {}),
      opu: OpuPhase.fromJson(json['opu'] ?? {}),
      embryology: EmbryologyPhase.fromJson(json['embryology'] ?? {}),
      transfer: TransferPhase.fromJson(json['transfer'] ?? {}),
      outcome: OutcomePhase.fromJson(json['outcome'] ?? {}),
      costs: CostInfo.fromJson(json['costs'] ?? {}),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'planned':
        return 'Planned';
      case 'active':
        return 'Active';
      case 'paused':
        return 'Paused';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pregnant':
        return 'Pregnant';
      default:
        return status;
    }
  }

  String get cycleTypeDisplay {
    switch (cycleType) {
      case 'IVF':
        return 'IVF';
      case 'IUI':
        return 'IUI';
      case 'ICSI':
        return 'ICSI';
      case 'FET':
        return 'FET';
      case 'Egg Freezing':
        return 'Egg Freezing';
      default:
        return cycleType;
    }
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isPregnant => status == 'pregnant';
}

class StimulationPhase {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<CycleMedication> medications;
  final List<MonitoringScan> monitoringScans;

  StimulationPhase({
    this.startDate,
    this.endDate,
    this.medications = const [],
    this.monitoringScans = const [],
  });

  factory StimulationPhase.fromJson(Map<String, dynamic> json) {
    return StimulationPhase(
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      medications: (json['medications'] as List?)
              ?.map((e) => CycleMedication.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      monitoringScans: (json['monitoringScans'] as List?)
              ?.map((e) => MonitoringScan.fromJson(e as Map<String, dynamic>))
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

class MonitoringScan {
  final DateTime date;
  final int? follicleCount;
  final List<int> follicleSizes;
  final double? endometrialThickness;
  final String notes;

  MonitoringScan({
    required this.date,
    this.follicleCount,
    this.follicleSizes = const [],
    this.endometrialThickness,
    this.notes = '',
  });

  factory MonitoringScan.fromJson(Map<String, dynamic> json) {
    return MonitoringScan(
      date: DateTime.parse(json['date']),
      follicleCount: json['follicleCount']?.toInt(),
      follicleSizes: (json['follicleSizes'] as List?)?.map((e) => e as int).toList() ?? [],
      endometrialThickness: json['endometrialThickness']?.toDouble(),
      notes: json['notes'] ?? '',
    );
  }
}

class TriggerPhase {
  final DateTime? date;
  final String medication;
  final String dosage;
  final DateTime? opuScheduled;

  TriggerPhase({
    this.date,
    this.medication = '',
    this.dosage = '',
    this.opuScheduled,
  });

  factory TriggerPhase.fromJson(Map<String, dynamic> json) {
    return TriggerPhase(
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      medication: json['medication'] ?? '',
      dosage: json['dosage'] ?? '',
      opuScheduled: json['opuScheduled'] != null ? DateTime.parse(json['opuScheduled']) : null,
    );
  }
}

class OpuPhase {
  final DateTime? date;
  final int? eggsRetrieved;
  final int? matureEggs;
  final String complications;

  OpuPhase({
    this.date,
    this.eggsRetrieved,
    this.matureEggs,
    this.complications = '',
  });

  factory OpuPhase.fromJson(Map<String, dynamic> json) {
    return OpuPhase(
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      eggsRetrieved: json['eggsRetrieved']?.toInt(),
      matureEggs: json['matureEggs']?.toInt(),
      complications: json['complications'] ?? '',
    );
  }
}

class EmbryologyPhase {
  final String fertilizationMethod;
  final int? fertilized;
  final int? day3Embryos;
  final int? day5Blastocysts;
  final int? cryopreserved;
  final String notes;

  EmbryologyPhase({
    this.fertilizationMethod = '',
    this.fertilized,
    this.day3Embryos,
    this.day5Blastocysts,
    this.cryopreserved,
    this.notes = '',
  });

  factory EmbryologyPhase.fromJson(Map<String, dynamic> json) {
    return EmbryologyPhase(
      fertilizationMethod: json['fertilizationMethod'] ?? '',
      fertilized: json['fertilized']?.toInt(),
      day3Embryos: json['day3Embryos']?.toInt(),
      day5Blastocysts: json['day5Blastocysts']?.toInt(),
      cryopreserved: json['cryopreserved']?.toInt(),
      notes: json['notes'] ?? '',
    );
  }
}

class TransferPhase {
  final DateTime? date;
  final String type;
  final int? embryosTransferred;
  final String embryoQuality;
  final String complications;

  TransferPhase({
    this.date,
    this.type = '',
    this.embryosTransferred,
    this.embryoQuality = '',
    this.complications = '',
  });

  factory TransferPhase.fromJson(Map<String, dynamic> json) {
    return TransferPhase(
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      type: json['type'] ?? '',
      embryosTransferred: json['embryosTransferred']?.toInt(),
      embryoQuality: json['embryoQuality'] ?? '',
      complications: json['complications'] ?? '',
    );
  }
}

class OutcomePhase {
  final DateTime? pregnancyTestDate;
  final String pregnancyTestResult;
  final double? hcgLevel;
  final bool? heartbeatDetected;
  final DateTime? deliveryDate;
  final String deliveryType;
  final int? babyCount;
  final String notes;

  OutcomePhase({
    this.pregnancyTestDate,
    this.pregnancyTestResult = '',
    this.hcgLevel,
    this.heartbeatDetected,
    this.deliveryDate,
    this.deliveryType = '',
    this.babyCount,
    this.notes = '',
  });

  factory OutcomePhase.fromJson(Map<String, dynamic> json) {
    return OutcomePhase(
      pregnancyTestDate: json['pregnancyTestDate'] != null ? DateTime.parse(json['pregnancyTestDate']) : null,
      pregnancyTestResult: json['pregnancyTestResult'] ?? '',
      hcgLevel: json['hcgLevel']?.toDouble(),
      heartbeatDetected: json['heartbeatDetected'],
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      deliveryType: json['deliveryType'] ?? '',
      babyCount: json['babyCount']?.toInt(),
      notes: json['notes'] ?? '',
    );
  }
}

class CostInfo {
  final int? estimatedCost;
  final int? actualCost;
  final int? insuranceCoverage;
  final String paymentStatus;

  CostInfo({
    this.estimatedCost,
    this.actualCost,
    this.insuranceCoverage,
    this.paymentStatus = 'pending',
  });

  factory CostInfo.fromJson(Map<String, dynamic> json) {
    return CostInfo(
      estimatedCost: json['estimatedCost']?.toInt(),
      actualCost: json['actualCost']?.toInt(),
      insuranceCoverage: json['insuranceCoverage']?.toInt(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
    );
  }
}
