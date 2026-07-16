class Appointment {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String doctorId;
  final String doctorName;
  final String clinic;
  final DateTime date;
  final String time;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.doctorId,
    required this.doctorName,
    required this.clinic,
    required this.date,
    required this.time,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userId'] != null && json['userId'] is Map 
          ? json['userId']['name'] 
          : json['userName'],
      userEmail: json['userId'] != null && json['userId'] is Map 
          ? json['userId']['email'] 
          : json['userEmail'],
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      clinic: json['clinic'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      status: json['status'] ?? 'upcoming',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'clinic': clinic,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get isUpcoming => status == 'upcoming';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
