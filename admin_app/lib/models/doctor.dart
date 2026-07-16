class Doctor {
  final String id;
  final String name;
  final String photo;
  final String qualification;
  final int experience;
  final String specialization;
  final double rating;
  final int reviewCount;
  final List<String> languages;
  final bool availableToday;
  final String clinic;
  final String about;
  final List<String> education;
  final double successRate;
  final int consultationFee;
  final List<String> availableSlots;
  final List<DoctorReview> reviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.name,
    this.photo = '',
    this.qualification = '',
    required this.experience,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.languages,
    required this.availableToday,
    required this.clinic,
    this.about = '',
    required this.education,
    required this.successRate,
    required this.consultationFee,
    required this.availableSlots,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'] ?? '',
      qualification: json['qualification'] ?? '',
      experience: json['experience'] ?? 0,
      specialization: json['specialization'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      languages: (json['languages'] as List?)?.map((e) => e.toString()).toList() ?? [],
      availableToday: json['availableToday'] ?? true,
      clinic: json['clinic'] ?? '',
      about: json['about'] ?? '',
      education: (json['education'] as List?)?.map((e) => e.toString()).toList() ?? [],
      successRate: json['successRate']?.toDouble() ?? 0.0,
      consultationFee: json['consultationFee'] ?? 0,
      availableSlots: (json['availableSlots'] as List?)?.map((e) => e.toString()).toList() ?? [],
      reviews: (json['reviews'] as List?)
              ?.map((e) => DoctorReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  bool get isAvailable => availableToday;
}

class DoctorReview {
  final String patientName;
  final double rating;
  final String comment;
  final String date;

  DoctorReview({
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory DoctorReview.fromJson(Map<String, dynamic> json) {
    return DoctorReview(
      patientName: json['patientName'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
