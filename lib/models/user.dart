class User {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  final String phone;
  final String email;
  final String medicalHistory;
  final String photo;
  final String partnerName;
  final String tryingSince;
  final int previousIvfAttempts;
  final int menstrualCycleDays;
  final String height;
  final String weight;
  final String allergies;
  final String currentMedications;
  final String maritalStatus;
  final bool profileComplete;

  User({
    this.id = '',
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    required this.email,
    required this.medicalHistory,
    required this.photo,
    this.partnerName = '',
    this.tryingSince = '',
    this.previousIvfAttempts = 0,
    this.menstrualCycleDays = 28,
    this.height = '',
    this.weight = '',
    this.allergies = '',
    this.currentMedications = '',
    this.maritalStatus = '',
    this.profileComplete = false,
  });

  User copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? bloodGroup,
    String? phone,
    String? email,
    String? medicalHistory,
    String? photo,
    String? partnerName,
    String? tryingSince,
    int? previousIvfAttempts,
    int? menstrualCycleDays,
    String? height,
    String? weight,
    String? allergies,
    String? currentMedications,
    String? maritalStatus,
    bool? profileComplete,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      photo: photo ?? this.photo,
      partnerName: partnerName ?? this.partnerName,
      tryingSince: tryingSince ?? this.tryingSince,
      previousIvfAttempts: previousIvfAttempts ?? this.previousIvfAttempts,
      menstrualCycleDays: menstrualCycleDays ?? this.menstrualCycleDays,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'Not specified',
      bloodGroup: json['bloodGroup'] ?? 'Not specified',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      medicalHistory: json['medicalHistory'] ?? '',
      photo: json['photo'] ?? '',
      partnerName: json['partnerName'] ?? '',
      tryingSince: json['tryingSince'] ?? '',
      previousIvfAttempts: json['previousIvfAttempts'] ?? 0,
      menstrualCycleDays: json['menstrualCycleDays'] ?? 28,
      height: json['height'] ?? '',
      weight: json['weight'] ?? '',
      allergies: json['allergies'] ?? '',
      currentMedications: json['currentMedications'] ?? '',
      maritalStatus: json['maritalStatus'] ?? '',
      profileComplete: json['profileComplete'] ??
          ((json['phone'] as String?)?.isNotEmpty == true &&
              (json['age'] as int? ?? 0) > 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'phone': phone,
      'email': email,
      'medicalHistory': medicalHistory,
      'photo': photo,
      'partnerName': partnerName,
      'tryingSince': tryingSince,
      'previousIvfAttempts': previousIvfAttempts,
      'menstrualCycleDays': menstrualCycleDays,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'maritalStatus': maritalStatus,
      'profileComplete': profileComplete,
    };
  }
}
