import 'dart:convert';

import 'package:flutter/services.dart';

class ScannedMealData {
  const ScannedMealData({
    required this.id,
    required this.dishName,
    required this.mealName,
    required this.mealType,
    required this.imageAsset,
    required this.matchPercent,
    required this.accuracy,
    required this.portionGrams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.ingredients,
    required this.insight,
  });

  final String id;
  final String dishName;
  final String mealName;
  final String mealType;
  final String imageAsset;
  final double matchPercent;
  final int accuracy;
  final int portionGrams;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final List<String> ingredients;
  final String insight;

  factory ScannedMealData.fromJson(Map<String, dynamic> json) {
    return ScannedMealData(
      id: json['id'] as String? ?? '',
      dishName: json['dishName'] as String? ?? 'Unknown Dish',
      mealName: json['mealName'] as String? ?? 'Detected Meal',
      mealType: json['mealType'] as String? ?? 'General Meal',
      imageAsset: json['imageAsset'] as String? ?? '',
      matchPercent: (json['matchPercent'] as num?)?.toDouble() ?? 90.0,
      accuracy: (json['accuracy'] as num?)?.toInt() ?? 90,
      portionGrams: (json['portionGrams'] as num?)?.toInt() ?? 250,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toInt() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toInt() ?? 0,
      fatsG: (json['fatsG'] as num?)?.toInt() ?? 0,
      ingredients: List<String>.from(json['ingredients'] as List? ?? const []),
      insight: json['insight'] as String? ?? '',
    );
  }
}

class ScanEvaluationResult {
  const ScanEvaluationResult({
    required this.meal,
    required this.matchedAllergens,
    required this.criticalIngredients,
    required this.profileNote,
  });

  final ScannedMealData meal;
  final List<String> matchedAllergens;
  final List<String> criticalIngredients;
  final String profileNote;

  bool get hasAllergyConflict => matchedAllergens.isNotEmpty;
}

class AllergenScanService {
  static const String _assetPath = 'assets/data/scan_mock_db.json';
  int _mockCursor = 0;

  Future<Map<String, dynamic>> _loadDb() async {
    final raw = await rootBundle.loadString(_assetPath);
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  ScanEvaluationResult _evaluateMealAgainstAllergies({
    required ScannedMealData meal,
    required List<String> userAllergies,
    required String profileNote,
    List<String> extraSearchableTexts = const [],
  }) {
    final matchedAllergens = <String>[];
    final criticalIngredients = <String>[];
    final searchableTexts = <String>[
      ...meal.ingredients,
      ...extraSearchableTexts,
    ];

    for (final allergy in userAllergies) {
      final normalizedAllergy = allergy.trim().toLowerCase();
      if (normalizedAllergy.isEmpty) continue;

      bool allergyHit = false;
      for (final itemText in searchableTexts) {
        final normalizedText = itemText.toLowerCase();
        if (normalizedText.contains(normalizedAllergy) ||
            normalizedAllergy.contains(normalizedText)) {
          allergyHit = true;
          if (!criticalIngredients.contains(itemText)) {
            criticalIngredients.add(itemText);
          }
        }
      }

      if (allergyHit && !matchedAllergens.contains(allergy)) {
        matchedAllergens.add(allergy);
      }
    }

    return ScanEvaluationResult(
      meal: meal,
      matchedAllergens: matchedAllergens,
      criticalIngredients: criticalIngredients,
      profileNote: profileNote,
    );
  }

  Future<ScanEvaluationResult> evaluateScan({String? imagePath}) async {
    final decoded = await _loadDb();

    final profile = decoded['userProfile'] as Map<String, dynamic>? ?? {};
    final userAllergies = List<String>.from(
      profile['allergies'] as List? ?? const [],
    );
    final profileNote =
        profile['profileNote'] as String? ?? 'Allergy Profile Active';

    final mealsJson = decoded['scanResults'] as List? ?? const [];
    final meals = mealsJson
        .map((e) => ScannedMealData.fromJson(e as Map<String, dynamic>))
        .toList();

    final selectedMeal = meals[_mockCursor % meals.length];
    _mockCursor++;

    return _evaluateMealAgainstAllergies(
      meal: selectedMeal,
      userAllergies: userAllergies,
      profileNote: profileNote,
    );
  }

  Future<ScanEvaluationResult> evaluateCustomFood({
    required String name,
    required int calories,
    List<String> ingredients = const [],
    String mealType = 'Searched Item',
    String imageAsset = 'assets/images/grilled_salmon_salad.png',
  }) async {
    final decoded = await _loadDb();

    final profile = decoded['userProfile'] as Map<String, dynamic>? ?? {};
    final userAllergies = List<String>.from(
      profile['allergies'] as List? ?? const [],
    );
    final profileNote =
        profile['profileNote'] as String? ?? 'Allergy Profile Active';

    final mealsJson = decoded['scanResults'] as List? ?? const [];
    final meals = mealsJson
        .map((e) => ScannedMealData.fromJson(e as Map<String, dynamic>))
        .toList();

    ScannedMealData? existingMatch;
    for (final m in meals) {
      if (m.dishName.toLowerCase() == name.trim().toLowerCase() ||
          m.mealName.toLowerCase() == name.trim().toLowerCase()) {
        existingMatch = m;
        break;
      }
    }

    final targetMeal =
        existingMatch ??
        ScannedMealData(
          id: 'search_${name.hashCode}',
          dishName: name,
          mealName: name,
          mealType: mealType,
          imageAsset: imageAsset,
          matchPercent: 95.0,
          accuracy: 95,
          portionGrams: 250,
          calories: calories,
          proteinG: (calories * 0.20 / 4).round(),
          carbsG: (calories * 0.45 / 4).round(),
          fatsG: (calories * 0.35 / 9).round(),
          ingredients: ingredients.isNotEmpty ? ingredients : [name],
          insight:
              'Estimated nutritional breakdown based on selected search item.',
        );

    return _evaluateMealAgainstAllergies(
      meal: targetMeal,
      userAllergies: userAllergies,
      profileNote: profileNote,
      extraSearchableTexts: [targetMeal.dishName, targetMeal.mealName],
    );
  }
}
