class DoctorReview {
  final String patientName;
  final int rating;
  final String comment;
  final String date;

  DoctorReview({
    this.patientName = '',
    this.rating = 5,
    this.comment = '',
    this.date = '',
  });

  factory DoctorReview.fromJson(Map<String, dynamic> json) {
    return DoctorReview(
      patientName: json['patientName'] ?? '',
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

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

  Doctor({
    required this.id,
    required this.name,
    required this.photo,
    required this.qualification,
    required this.experience,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.languages,
    required this.availableToday,
    required this.clinic,
    required this.about,
    required this.education,
    required this.successRate,
    required this.consultationFee,
    required this.availableSlots,
    this.reviews = const [],
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'] ?? '',
      qualification: json['qualification'] ?? '',
      experience: json['experience'] ?? 0,
      specialization: json['specialization'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      languages: List<String>.from(json['languages'] ?? []),
      availableToday: json['availableToday'] ?? false,
      clinic: json['clinic'] ?? '',
      about: json['about'] ?? '',
      education: List<String>.from(json['education'] ?? []),
      successRate: (json['successRate'] ?? 0).toDouble(),
      consultationFee: json['consultationFee'] ?? 0,
      availableSlots: List<String>.from(json['availableSlots'] ?? []),
      reviews: (json['reviews'] as List?)
              ?.map((r) => DoctorReview.fromJson(r))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'qualification': qualification,
      'experience': experience,
      'specialization': specialization,
      'rating': rating,
      'reviewCount': reviewCount,
      'languages': languages,
      'availableToday': availableToday,
      'clinic': clinic,
      'about': about,
      'education': education,
      'successRate': successRate,
      'consultationFee': consultationFee,
      'availableSlots': availableSlots,
    };
  }
}
