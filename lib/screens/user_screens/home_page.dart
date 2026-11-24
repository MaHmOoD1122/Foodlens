import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/local_auth_service.dart';
import '../../state.dart';
import '../../theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAll;
  final VoidCallback? onScan;

  const HomeScreen({super.key, this.onSeeAll, this.onScan});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDayIndex = 2;

  final List<_DayItem> _days = const [
    _DayItem('Mon', '12'),
    _DayItem('Tue', '13'),
    _DayItem('Wed', '14'),
    _DayItem('Thu', '15'),
    _DayItem('Fri', '16'),
    _DayItem('Sat', '17'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final user = LocalAuthService.instance.currentUser;
        final userName = user?.firstName ?? 'Alex';
        final targetCal = user?.targetCalories ?? 1850;
        final proteinGoal = user?.proteinTargetG ?? 120;
        final carbsGoal = user?.carbsTargetG ?? 210;
        final fatsGoal = user?.fatsTargetG ?? 60;

        final eatenCal = app.totalConsumedToday;
        final proteinEaten = app.totalProteinToday;
        final carbsEaten = app.totalCarbsToday;
        final fatsEaten = app.totalFatsToday;
        final meals = app.currentUserMeals;

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              _buildHeader(userName),
              const SizedBox(height: 14),
              _buildWeekStrip(),
              const SizedBox(height: 14),
              _buildCalorieCard(
                eatenCal: eatenCal,
                targetCal: targetCal,
                proteinEaten: proteinEaten,
                proteinGoal: proteinGoal,
                carbsEaten: carbsEaten,
                carbsGoal: carbsGoal,
                fatsEaten: fatsEaten,
                fatsGoal: fatsGoal,
              ),
              const SizedBox(height: 18),
              _buildMealsSection(meals),
              const SizedBox(height: 14),
              _buildSmartScanCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String userName) {
    return Row(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: C.lavender,
          child: const Icon(LucideIcons.user, color: C.text, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning', style: ts(11.5, color: C.sub)),
              Text(
                userName,
                style: ts(17, w: FontWeight.w800, color: C.text),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.cardBorder),
          ),
          child: const Icon(LucideIcons.bell, size: 19, color: C.text),
        ),
      ],
    );
  }

  Widget _buildWeekStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.cardBorder),
      ),
      child: Row(
        children: List.generate(_days.length, (index) {
          final item = _days[index];
          final selected = index == _selectedDayIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDayIndex = index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? C.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      item.day,
                      style: ts(
                        11,
                        w: FontWeight.w600,
                        color: selected ? Colors.white : C.sub,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.date,
                      style: ts(
                        13,
                        w: FontWeight.w800,
                        color: selected ? Colors.white : C.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalorieCard({
    required int eatenCal,
    required int targetCal,
    required int proteinEaten,
    required int proteinGoal,
    required int carbsEaten,
    required int carbsGoal,
    required int fatsEaten,
    required int fatsGoal,
  }) {
    final progress = targetCal > 0
        ? (eatenCal / targetCal).clamp(0.0, 1.0)
        : 0.0;
    final remainingCal = (targetCal - eatenCal).clamp(0, 99999);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: C.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 148,
                height: 148,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        backgroundColor: C.lavender,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          C.green,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$eatenCal',
                          style: ts(25, w: FontWeight.w900, color: C.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'of $targetCal kcal',
                          style: ts(11.5, color: C.sub),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildSummaryStat(
                      icon: LucideIcons.flag,
                      iconColor: C.green,
                      tintColor: C.greenTint,
                      label: 'Remaining',
                      value: '$remainingCal',
                    ),
                    const SizedBox(height: 14),
                    const _BurnedStat(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildMacroBar(
                  label: 'Protein ',
                  current: '$proteinEaten',
                  target: '/${proteinGoal}g',
                  accent: C.green,
                  ratio: proteinGoal > 0 ? proteinEaten / proteinGoal : 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroBar(
                  label: 'Carbs ',
                  current: '$carbsEaten',
                  target: '/${carbsGoal}g',
                  accent: C.orange,
                  ratio: carbsGoal > 0 ? carbsEaten / carbsGoal : 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroBar(
                  label: 'Fats ',
                  current: '$fatsEaten',
                  target: '/${fatsGoal}g',
                  accent: C.blue,
                  ratio: fatsGoal > 0 ? fatsEaten / fatsGoal : 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat({
    required IconData icon,
    required Color iconColor,
    required Color tintColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tintColor,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ts(11.5, color: C.sub)),
              const SizedBox(height: 1),
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: ts(16, w: FontWeight.w800, color: C.text),
                    ),
                    TextSpan(
                      text: ' kcal',
                      style: ts(11, color: C.sub),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBar({
    required String label,
    required String current,
    required String target,
    required Color accent,
    required double ratio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: ts(11, w: FontWeight.w700, color: C.text),
              ),
              TextSpan(
                text: current,
                style: ts(11, w: FontWeight.w800, color: accent),
              ),
              TextSpan(
                text: target,
                style: ts(10.5, color: C.sub),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: C.track,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }

  Widget _buildMealsSection(List<UserMeal> meals) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's meals",
              style: ts(17, w: FontWeight.w800, color: C.text),
            ),
            GestureDetector(
              onTap: widget.onSeeAll,
              child: Text(
                'See all',
                style: ts(12.5, w: FontWeight.w700, color: C.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (meals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: C.cardBorder),
            ),
            child: Column(
              children: [
                Text(
                  'No meals logged yet',
                  style: ts(14, w: FontWeight.w700, color: C.text),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scan a meal with Foodlens AI to start tracking.',
                  style: ts(12, color: C.sub),
                ),
              ],
            ),
          )
        else
          for (int i = 0; i < meals.length; i++) ...[
            _buildMealTile(meals[i]),
            if (i != meals.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _buildMealTile(UserMeal meal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: meal.hasAllergyWarning ? C.redAlertBorder : C.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: meal.hasAllergyWarning ? C.redTint : C.greenTint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              meal.hasAllergyWarning
                  ? Icons.warning_amber_rounded
                  : LucideIcons.utensils,
              size: 20,
              color: meal.hasAllergyWarning ? C.red : C.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  style: ts(13.5, w: FontWeight.w700, color: C.text),
                ),
                const SizedBox(height: 2),
                Text(
                  '${meal.mealType} · ${meal.timeLabel}',
                  style: ts(11.5, color: C.sub),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.kcal}',
                style: ts(15, w: FontWeight.w800, color: C.text),
              ),
              Text('kcal', style: ts(10.5, color: C.sub)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartScanCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: C.greenTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.greenBadge),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: C.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.sparkles,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Meal Logging',
                  style: ts(13, w: FontWeight.w800, color: C.text),
                ),
                const SizedBox(height: 2),
                Text(
                  'Snap a photo to analyze & log your meal',
                  style: ts(11, color: C.sub),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onScan,
            child: Text(
              'Try Scan',
              style: ts(12, w: FontWeight.w800, color: C.green),
            ),
          ),
        ],
      ),
    );
  }
}

class _BurnedStat extends StatelessWidget {
  const _BurnedStat();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: C.orangeTint,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(LucideIcons.flame, size: 17, color: C.orange),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Burned', style: ts(11.5, color: C.sub)),
              const SizedBox(height: 1),
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '0',
                      style: ts(16, w: FontWeight.w800, color: C.text),
                    ),
                    TextSpan(
                      text: ' kcal',
                      style: ts(11, color: C.sub),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayItem {
  final String day;
  final String date;
  const _DayItem(this.day, this.date);
}
