import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme.dart';
import './diary_page.dart';
import './home_page.dart';
import './scanner.dart';
import 'main_tabs.dart';

class DonePage extends StatelessWidget {
  final OnboardingData data;
  const DonePage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final rows = {
      'Allergies': data.noAllergies || data.allergies.isEmpty
          ? 'None'
          : data.allergies.join(', '),
      'Goal': data.goal.title,
      'Activity': data.activity.label,
      'Sex': data.sex.name,
      'Height': '${data.heightCm.round()} cm',
      'Weight': '${data.weightKg.toStringAsFixed(1)} kg',
      'Age': '${data.age}',
      'Daily target': '${data.targetCalories} kcal',
      'Doctor': data.doctor?.name ?? 'Solo',
    };
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('All set!'), backgroundColor: C.bg),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in rows.entries)
            ListTile(title: Text(e.key), trailing: Text(e.value)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainTabsScreen(initialIndex: 0),
                  ),
                  (_) => false,
                );
              },
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
