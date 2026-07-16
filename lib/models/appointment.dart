class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String clinic;
  final DateTime date;
  final String time;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.clinic,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? json['id'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      clinic: json['clinic'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.${json['status']}',
        orElse: () => AppointmentStatus.upcoming,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'clinic': clinic,
      'date': date.toIso8601String(),
      'time': time,
      'status': status.toString().split('.').last,
    };
  }
}

enum AppointmentStatus {
  upcoming,
  completed,
  cancelled,
}
