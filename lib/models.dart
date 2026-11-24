import 'package:flutter/material.dart';

enum Sex { male, female, neutral }

class Allergen {
  final String name, note;
  final IconData icon;
  final bool highAlert;
  const Allergen(this.name, this.note, this.icon, {this.highAlert = false});
}

class GoalOption {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final int calorieDelta;
  const GoalOption(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.calorieDelta,
  );
}

class ActivityLevel {
  final String label;
  final double factor;
  const ActivityLevel(this.label, this.factor);
}

class Doctor {
  final String name, org, title;
  final String code;
  final String specialty;
  final String licenseNumber;
  final String approvalStatus; // 'pending' | 'approved' | 'rejected'
  final String accountStatus; // 'active' | 'suspended'

  const Doctor(
    this.name,
    this.org,
    this.title, {
    this.code = '',
    this.specialty = 'Clinical Nutrition',
    this.licenseNumber = '',
    this.approvalStatus = 'approved',
    this.accountStatus = 'active',
  });
}

const allergens = [
  Allergen('Peanuts', 'High alert', Icons.spa, highAlert: true),
  Allergen('Tree Nuts', 'High alert', Icons.park, highAlert: true),
  Allergen('Dairy', 'Lactose', Icons.local_drink),
  Allergen('Gluten', 'Wheat', Icons.bakery_dining),
  Allergen('Shellfish', 'High alert', Icons.set_meal, highAlert: true),
  Allergen('Eggs', 'All types', Icons.egg),
  Allergen('Soy', 'Legumes', Icons.grass),
  Allergen('Fish', 'Seafood', Icons.phishing),
  Allergen('Sesame', 'Seeds & oils', Icons.circle_outlined),
];

const goals = [
  GoalOption(
    'Lose weight',
    'Gentle calorie deficit',
    Icons.trending_down,
    Colors.green,
    -500,
  ),
  GoalOption(
    'Maintain weight',
    'Stay balanced and healthy',
    Icons.balance,
    Colors.indigo,
    0,
  ),
  GoalOption(
    'Build muscle',
    'High protein surplus',
    Icons.trending_up,
    Colors.deepOrange,
    300,
  ),
];

const activityLevels = [
  ActivityLevel('Light', 1.375),
  ActivityLevel('Moderate', 1.55),
  ActivityLevel('Very active', 1.725),
];

const clinicRegistry = {
  'DOC-8849': Doctor(
    'Dr. David Vance, MS, RD',
    'Metropolitan Clinical Nutrition & Allergy Center',
    'Verified Dietitian',
    code: 'DOC-8849',
    specialty: 'Clinical Dietetics & Metabolism',
    licenseNumber: 'LIC-8849-RD',
    approvalStatus: 'approved',
    accountStatus: 'active',
  ),
};

Future<Doctor?> findClinic(String code) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return clinicRegistry[code.trim().toUpperCase()];
}

class OnboardingData {
  String fullName = '';
  String email = '';
  String password = '';

  // بيانات الـ 4 صفحات
  final Set<String> allergies = {};
  bool noAllergies = false;
  GoalOption goal = goals[0];
  ActivityLevel activity = activityLevels[1];
  int calorieAdjust = 0;
  Sex sex = Sex.male;
  double heightCm = 175;
  double weightKg = 74.5;
  int age = 28;
  Doctor? doctor;

  int get targetCalories {
    final s = switch (sex) {
      Sex.male => 5,
      Sex.female => -161,
      Sex.neutral => -78,
    };
    final bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + s;
    return (bmr * activity.factor + goal.calorieDelta + calorieAdjust).round();
  }

  Map<String, dynamic> toUserJson(String id) => {
    'id': id,
    'fullName': fullName.trim().isEmpty ? 'User' : fullName.trim(),
    'email': email.trim().toLowerCase(),
    'password': password,
    'role': 'user',
    'accountStatus': 'active',
    'allergies': allergies.toList(),
    'noAllergies': noAllergies,
    'goalTitle': goal.title,
    'activityLabel': activity.label,
    'calorieAdjust': calorieAdjust,
    'sex': sex.name,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'age': age,
    'targetCalories': targetCalories,
    'doctorCode': doctor?.code,
    'doctorName': doctor?.name,
  };
}

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String role; // 'user' | 'doctor' | 'admin'
  final String approvalStatus; // 'pending' | 'approved' | 'rejected' (للدكتور)
  final String accountStatus; // 'active' | 'suspended'
  final String? clinicCode;
  final String? org;
  final String? specialty;
  final String? licenseNumber;
  final List<String> allergies;
  final bool noAllergies;
  final String goalTitle;
  final String activityLabel;
  final String sex;
  final double heightCm;
  final double weightKg;
  final int age;
  final int targetCalories;
  final String? doctorCode;
  final String? doctorName;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.approvalStatus = 'approved',
    this.accountStatus = 'active',
    this.clinicCode,
    this.org,
    this.specialty,
    this.licenseNumber,
    this.allergies = const [],
    this.noAllergies = true,
    this.goalTitle = 'Maintain weight',
    this.activityLabel = 'Moderate',
    this.sex = 'male',
    this.heightCm = 175.0,
    this.weightKg = 70.0,
    this.age = 25,
    this.targetCalories = 2000,
    this.doctorCode,
    this.doctorName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] as String?) ?? 'user';
    return AppUser(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'User',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: role,
      approvalStatus:
          json['approvalStatus'] ?? (role == 'doctor' ? 'pending' : 'approved'),
      accountStatus: json['accountStatus'] ?? 'active',
      clinicCode: json['clinicCode'],
      org: json['org'],
      specialty: json['specialty'] ?? json['title'],
      licenseNumber: json['licenseNumber'],
      allergies: List<String>.from(json['allergies'] ?? const []),
      noAllergies: json['noAllergies'] ?? true,
      goalTitle: json['goalTitle'] ?? 'Maintain weight',
      activityLabel: json['activityLabel'] ?? 'Moderate',
      sex: json['sex'] ?? 'male',
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70.0,
      age: (json['age'] as num?)?.toInt() ?? 25,
      targetCalories: (json['targetCalories'] as num?)?.toInt() ?? 2000,
      doctorCode: json['doctorCode'],
      doctorName: json['doctorName'],
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isDoctor => role == 'doctor';
  bool get isUser => role == 'user';
  bool get isPendingDoctor => isDoctor && approvalStatus == 'pending';
  bool get isApprovedDoctor => isDoctor && approvalStatus == 'approved';
  bool get isSuspended => accountStatus == 'suspended';

  String get firstName => fullName.trim().split(' ').first;

  double get bmi {
    final hMeters = heightCm / 100;
    if (hMeters <= 0) return 0;
    return weightKg / (hMeters * hMeters);
  }

  String get bmiLabel {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Healthy';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  int get proteinTargetG => ((targetCalories * 0.30) / 4).round();
  int get carbsTargetG => ((targetCalories * 0.45) / 4).round();
  int get fatsTargetG => ((targetCalories * 0.25) / 9).round();
}
