import 'package:flutter/material.dart';

import 'models.dart';
import 'services/local_auth_service.dart';

class UserMeal {
  final String id;
  final String title;
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final String timeLabel;
  final int grams;
  final int kcal;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final bool hasAllergyWarning;
  final String? imagePath;

  const UserMeal({
    required this.id,
    required this.title,
    required this.mealType,
    required this.timeLabel,
    required this.grams,
    required this.kcal,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatsG = 0,
    this.hasAllergyWarning = false,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'mealType': mealType,
    'timeLabel': timeLabel,
    'grams': grams,
    'kcal': kcal,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatsG': fatsG,
    'hasAllergyWarning': hasAllergyWarning,
    'imagePath': imagePath,
  };

  factory UserMeal.fromJson(Map<String, dynamic> json) => UserMeal(
    id: json['id'] ?? '',
    title: json['title'] ?? 'Meal',
    mealType: json['mealType'] ?? 'Meal',
    timeLabel: json['timeLabel'] ?? 'Today',
    grams: (json['grams'] as num?)?.toInt() ?? 200,
    kcal: (json['kcal'] as num?)?.toInt() ?? 0,
    proteinG: (json['proteinG'] as num?)?.toInt() ?? 0,
    carbsG: (json['carbsG'] as num?)?.toInt() ?? 0,
    fatsG: (json['fatsG'] as num?)?.toInt() ?? 0,
    hasAllergyWarning: json['hasAllergyWarning'] ?? false,
    imagePath: json['imagePath'],
  );
}

class Patient {
  final String id;
  final String name;
  final String initials;
  final int age;
  final String sex;
  final String plan;
  final String status;
  final int adh;
  final int consumed;
  final int ceiling;
  final int protein;
  final int carbs;
  final int fat;
  final bool allergy;
  final String allergyTxt;
  final bool over;
  final String last;
  final String note;
  final bool gate;

  const Patient({
    required this.id,
    required this.name,
    required this.initials,
    required this.age,
    required this.sex,
    required this.plan,
    required this.status,
    required this.adh,
    required this.consumed,
    required this.ceiling,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.allergy,
    required this.allergyTxt,
    required this.over,
    required this.last,
    required this.note,
    required this.gate,
  });

  Patient copyWith({
    int? ceiling,
    int? protein,
    int? carbs,
    int? fat,
    String? note,
    bool? gate,
    int? consumed,
  }) {
    final newCeiling = ceiling ?? this.ceiling;
    final newConsumed = consumed ?? this.consumed;
    return Patient(
      id: id,
      name: name,
      initials: initials,
      age: age,
      sex: sex,
      plan: plan,
      status: status,
      adh: adh,
      consumed: newConsumed,
      ceiling: newCeiling,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      allergy: allergy,
      allergyTxt: allergyTxt,
      over: newConsumed > newCeiling,
      last: last,
      note: note ?? this.note,
      gate: gate ?? this.gate,
    );
  }
}

class Protocol {
  final int id;
  final String name;
  final int kcal;
  final int carb;
  final int prot;
  final int fat;
  final String cat;
  final String badge;
  final String desc;
  final int assigned;
  final List<String> allergens;

  const Protocol({
    required this.id,
    required this.name,
    required this.kcal,
    required this.carb,
    required this.prot,
    required this.fat,
    required this.cat,
    required this.badge,
    required this.desc,
    this.assigned = 0,
    this.allergens = const [],
  });

  Protocol copyWith({int? assigned}) => Protocol(
    id: id,
    name: name,
    kcal: kcal,
    carb: carb,
    prot: prot,
    fat: fat,
    cat: cat,
    badge: badge,
    desc: desc,
    assigned: assigned ?? this.assigned,
    allergens: allergens,
  );

  int grams(String macro) {
    return switch (macro) {
      'carb' => ((kcal * (carb / 100)) / 4).round(),
      'prot' => ((kcal * (prot / 100)) / 4).round(),
      'fat' => ((kcal * (fat / 100)) / 9).round(),
      _ => 0,
    };
  }
}

class AlertItem {
  final String id;
  final String pid;
  final String type; // 'allergy' | 'calorie'
  final String title;
  final String time;
  final String? item;
  final String detail;
  final bool resolved;

  const AlertItem({
    required this.id,
    required this.pid,
    required this.type,
    required this.title,
    required this.time,
    this.item,
    required this.detail,
    this.resolved = false,
  });

  AlertItem copyWith({bool? resolved}) => AlertItem(
    id: id,
    pid: pid,
    type: type,
    title: title,
    time: time,
    item: item,
    detail: detail,
    resolved: resolved ?? this.resolved,
  );
}

class AppState extends ChangeNotifier {
  AppState() {
    LocalAuthService.instance.addListener(_syncWithAuth);
    _syncWithAuth();
  }

  final Map<String, List<UserMeal>> _mealsByUserId = {};
  List<Patient> _patients = const [];
  final List<AlertItem> _alerts = [];
  List<Protocol> _protocols = [
    const Protocol(
      id: 1,
      name: 'High-Protein Metabolic Cut',
      kcal: 1800,
      carb: 35,
      prot: 40,
      fat: 25,
      cat: 'Weight Loss',
      badge: 'Clinical',
      desc: 'Preserves lean tissue during moderate calorie deficit.',
      assigned: 1,
      allergens: ['Peanuts'],
    ),
    const Protocol(
      id: 2,
      name: 'Balanced Glycemic Control',
      kcal: 2000,
      carb: 45,
      prot: 30,
      fat: 25,
      cat: 'Diabetes',
      badge: 'Evidence-Based',
      desc: 'Low-glycemic distribution with steady macro ratios.',
      assigned: 0,
      allergens: [],
    ),
  ];

  String get doctorName =>
      LocalAuthService.instance.currentUser?.fullName ?? 'Dr. Clinician';

  List<UserMeal> get currentUserMeals {
    final uid = LocalAuthService.instance.currentUser?.id ?? 'guest';
    return List.unmodifiable(_mealsByUserId[uid] ?? const []);
  }

  int get totalConsumedToday =>
      currentUserMeals.fold(0, (sum, m) => sum + m.kcal);

  int get totalProteinToday =>
      currentUserMeals.fold(0, (sum, m) => sum + m.proteinG);

  int get totalCarbsToday =>
      currentUserMeals.fold(0, (sum, m) => sum + m.carbsG);

  int get totalFatsToday => currentUserMeals.fold(0, (sum, m) => sum + m.fatsG);

  void logMealForCurrentUser({
    required String title,
    required int kcal,
    int grams = 250,
    String mealType = 'Meal',
    int proteinG = 0,
    int carbsG = 0,
    int fatsG = 0,
    bool hasAllergyWarning = false,
    String? imagePath,
  }) {
    final uid = LocalAuthService.instance.currentUser?.id ?? 'guest';
    final existing = List<UserMeal>.from(_mealsByUserId[uid] ?? const []);
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final min = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';

    existing.insert(
      0,
      UserMeal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        mealType: mealType,
        timeLabel: '$hour:$min $period · ${grams}g',
        grams: grams,
        kcal: kcal,
        proteinG: proteinG,
        carbsG: carbsG,
        fatsG: fatsG,
        hasAllergyWarning: hasAllergyWarning,
        imagePath: imagePath,
      ),
    );
    _mealsByUserId[uid] = existing;
    notifyListeners();
  }

  void _syncWithAuth() {
    LocalAuthService.instance.getPatients().then((users) {
      _patients = users.map(_mapAppUserToPatient).toList();
      notifyListeners();
    });
  }

  Patient _mapAppUserToPatient(AppUser u) {
    final parts = u.fullName.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : (parts.first.isNotEmpty ? parts.first[0].toUpperCase() : 'PT');
    final meals = _mealsByUserId[u.id] ?? const [];
    final consumed = meals.fold<int>(0, (acc, m) => acc + m.kcal);
    final ceiling = u.targetCalories > 0 ? u.targetCalories : 1850;
    final hasAllergy = !u.noAllergies && u.allergies.isNotEmpty;

    return Patient(
      id: u.id,
      name: u.fullName,
      initials: initials,
      age: u.age,
      sex: u.sex,
      plan: u.goalTitle,
      status: meals.isEmpty
          ? 'No scans yet'
          : (consumed > ceiling ? 'Over ceiling' : 'On track'),
      adh: meals.isEmpty ? 0 : (consumed <= ceiling ? 95 : 75),
      consumed: consumed,
      ceiling: ceiling,
      protein: u.proteinTargetG,
      carbs: u.carbsTargetG,
      fat: u.fatsTargetG,
      allergy: hasAllergy,
      allergyTxt: hasAllergy ? u.allergies.join(', ') : 'No allergies',
      over: consumed > ceiling,
      last: meals.isEmpty ? 'No scan yet' : meals.first.title,
      note: u.doctorName != null ? 'Synced with ${u.doctorName}' : '',
      gate: hasAllergy,
    );
  }

  List<Patient> get patients => List.unmodifiable(_patients);

  Patient patient(String id) => _patients.firstWhere(
    (p) => p.id == id,
    orElse: () => const Patient(
      id: 'PT-000',
      name: 'Patient',
      initials: 'PT',
      age: 25,
      sex: 'male',
      plan: 'Maintain weight',
      status: 'No scans yet',
      adh: 0,
      consumed: 0,
      ceiling: 2000,
      protein: 150,
      carbs: 225,
      fat: 56,
      allergy: false,
      allergyTxt: 'No allergies',
      over: false,
      last: 'No scan yet',
      note: '',
      gate: false,
    ),
  );

  int get avgAdherence {
    if (_patients.isEmpty) return 0;
    final total = _patients.fold<int>(0, (s, p) => s + p.adh);
    return (total / _patients.length).round();
  }

  List<AlertItem> get openAlerts =>
      _alerts.where((a) => !a.resolved).toList(growable: false);

  bool hasCritical(String patientId) => _alerts.any(
    (a) => !a.resolved && a.pid == patientId && a.type == 'allergy',
  );

  void resolve(String alertId) {
    final idx = _alerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      _alerts[idx] = _alerts[idx].copyWith(resolved: true);
      notifyListeners();
    }
  }

  void publishTargets(
    String patientId, {
    required int ceiling,
    required int protein,
    required int carbs,
    required int fat,
    required String note,
    required bool gate,
  }) {
    final idx = _patients.indexWhere((p) => p.id == patientId);
    if (idx != -1) {
      _patients[idx] = _patients[idx].copyWith(
        ceiling: ceiling,
        protein: protein,
        carbs: carbs,
        fat: fat,
        note: note,
        gate: gate,
      );
      notifyListeners();
    }
  }

  List<Protocol> get protocols => List.unmodifiable(_protocols);

  void addProtocol(Protocol protocol) {
    _protocols = [protocol, ..._protocols];
    notifyListeners();
  }

  void deleteProtocol(int id) {
    _protocols = _protocols.where((p) => p.id != id).toList();
    notifyListeners();
  }

  void assign(int protocolId, String patientId) {
    _protocols = _protocols
        .map(
          (p) => p.id == protocolId ? p.copyWith(assigned: p.assigned + 1) : p,
        )
        .toList();
    notifyListeners();
  }

  String _registeredDoctorName = '';
  String get registeredDoctorName =>
      _registeredDoctorName.isNotEmpty ? _registeredDoctorName : doctorName;

  void register(String doctorName) {
    _registeredDoctorName = doctorName.trim();
    notifyListeners();
  }
}

final app = AppState();
