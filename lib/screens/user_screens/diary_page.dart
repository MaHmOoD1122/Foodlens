import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state.dart';
import '../../theme.dart';
import '../../widgets.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  int _range = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final meals = app.currentUserMeals;
        final totalToday = app.totalConsumedToday;

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Diary', style: ts(22, w: FontWeight.w800)),
                  SegToggle(
                    items: const ['Week', 'Month'],
                    index: _range,
                    onChanged: (i) => setState(() => _range = i),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Logged today', style: ts(11, color: C.sub)),
                        Pill(
                          '${meals.length} ${meals.length == 1 ? 'meal' : 'meals'}',
                          bg: C.greenTint,
                          fg: C.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$totalToday', style: ts(26, w: FontWeight.w800)),
                        const SizedBox(width: 4),
                        Text('kcal', style: ts(12, color: C.sub)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    WeekBarChart(
                      values: [0, 0, 0, 0, 0, 0, totalToday.toDouble()],
                      height: 160,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionHeader(
                'Today',
                trailing: Text('$totalToday kcal', style: ts(11, color: C.sub)),
              ),
              const SizedBox(height: 10),
              if (meals.isEmpty)
                AppCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No scans or meals logged for this account yet.',
                        style: ts(12.5, color: C.sub),
                      ),
                    ),
                  ),
                )
              else
                for (final m in meals) ...[
                  MealTile(
                    icon: LucideIcons.utensils,
                    color: m.hasAllergyWarning ? C.red : C.green,
                    tint: m.hasAllergyWarning ? C.redTint : C.greenTint,
                    title: m.title,
                    subtitle: m.timeLabel,
                    kcal: m.kcal,
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        );
      },
    );
  }
}
