enum TreatmentStatus {
  completed,
  inProgress,
  locked,
}

class TreatmentStep {
  final String id;
  final String title;
  final String description;
  final TreatmentStatus status;
  final String? date;

  TreatmentStep({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.date,
  });

  factory TreatmentStep.fromJson(Map<String, dynamic> json) {
    return TreatmentStep(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: _parseStatus(json['status']),
      date: json['date'],
    );
  }

  static TreatmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'completed':
        return TreatmentStatus.completed;
      case 'inProgress':
        return TreatmentStatus.inProgress;
      default:
        return TreatmentStatus.locked;
    }
  }
}
