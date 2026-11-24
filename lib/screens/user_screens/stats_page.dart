import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/local_auth_service.dart';
import '../../theme.dart';
import '../../widgets.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _range = 0;

  @override
  Widget build(BuildContext context) {
    final user = LocalAuthService.instance.currentUser;
    final userName = user?.firstName ?? 'Alex';
    final targetCal = user?.targetCalories ?? 1850;
    final proteinGoal = user?.proteinTargetG ?? 120;
    final carbsGoal = user?.carbsTargetG ?? 210;
    final fatsGoal = user?.fatsTargetG ?? 60;
    final allergies = user?.allergies ?? const <String>[];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Row(
            children: [
              const Avatar(size: 36),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Analytics Hub', style: ts(10.5, color: C.sub)),
                  Text(userName, style: ts(16, w: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              const NotifBell(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Statistics', style: ts(22, w: FontWeight.w800)),
              SegToggle(
                items: const ['Week', 'Month', 'Year'],
                index: _range,
                onChanged: (i) => setState(() => _range = i),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: C.greenTint,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: C.green.withOpacity(.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.circleCheck,
                      size: 14,
                      color: C.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Weekly Nutrition Score: 92/100',
                      style: ts(11, w: FontWeight.w700, color: C.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'On Track',
                style: ts(11, w: FontWeight.w800, color: C.green),
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
                    Text('Daily average', style: ts(11, color: C.sub)),
                    const Pill('↘ 6% vs last wk', bg: C.greenTint, fg: C.green),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('1,742', style: ts(26, w: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('kcal', style: ts(12, color: C.sub)),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Target baseline: $targetCal kcal',
                          style: ts(10, color: C.sub),
                        ),
                        Text(
                          'Deficit: -108 kcal/day',
                          style: ts(10.5, w: FontWeight.w800, color: C.green),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                WeekBarChart(
                  values: const [1500, 1800, 2000, 1500, 1700, 1950, 1744],
                  goal: targetCal.toDouble(),
                  height: 150,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Macronutrient Balance',
                      style: ts(14, w: FontWeight.w800),
                    ),
                    Text('Avg / Day', style: ts(10, color: C.sub)),
                  ],
                ),
                const SizedBox(height: 14),
                _macro(
                  'Protein',
                  C.green,
                  118,
                  proteinGoal,
                  proteinGoal > 0
                      ? ((118 / proteinGoal) * 100).round().clamp(0, 100)
                      : 0,
                ),
                const SizedBox(height: 12),
                _macro(
                  'Carbohydrates',
                  C.orange,
                  185,
                  carbsGoal,
                  carbsGoal > 0
                      ? ((185 / carbsGoal) * 100).round().clamp(0, 100)
                      : 0,
                ),
                const SizedBox(height: 12),
                _macro(
                  'Fats',
                  C.blue,
                  48,
                  fatsGoal,
                  fatsGoal > 0
                      ? ((48 / fatsGoal) * 100).round().clamp(0, 100)
                      : 0,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: C.border)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _ratio('32% P'),
                        const VerticalDivider(width: 1, color: C.border),
                        _ratio('46% C'),
                        const VerticalDivider(width: 1, color: C.border),
                        _ratio('22% F'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Weight Journey', style: ts(14, w: FontWeight.w800)),
                    const Pill('-1.5 kg', bg: C.greenTint, fg: C.green),
                  ],
                ),
                Text('Past 4 weeks trend', style: ts(10.5, color: C.sub)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: C.lavender,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _weightBox('Start', '76.0', false),
                      _weightBox(
                        'Current',
                        (user?.weightKg ?? 74.5).toStringAsFixed(1),
                        true,
                      ),
                      _weightBox('Target', '72.0', false),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _week('Week 1', '(76.0)', false),
                    _week('Week 2', '(75.4)', false),
                    _week('Week 3', '(74.9)', false),
                    _week(
                      'Week 4',
                      '(${(user?.weightKg ?? 74.5).toStringAsFixed(1)})',
                      true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: .375),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LayoutBuilder(
                    builder: (_, c) => SizedBox(
                      height: 14,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          ProgressBar(value: v, color: C.green, height: 6),
                          Positioned(
                            left: (c.maxWidth - 14) * v,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: C.green, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '37.5% of total 4.0 kg goal achieved',
                      style: ts(10, color: C.sub),
                    ),
                    Text(
                      '2.5 kg remaining',
                      style: ts(10, w: FontWeight.w800, color: C.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Row(
              children: [
                const IconBox(
                  LucideIcons.shieldCheck,
                  color: C.green,
                  tint: C.greenTint,
                  size: 42,
                  radius: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Allergen Guard', style: ts(13, w: FontWeight.w800)),
                      Text(
                        '0 allergen exposures flagged this week',
                        style: ts(10.5, color: C.sub),
                      ),
                      Text(
                        allergies.isNotEmpty
                            ? '${allergies.join(', ')} protected'
                            : 'No allergens configured',
                        style: ts(10, w: FontWeight.w800, color: C.green),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.circleCheck, color: C.green, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macro(String label, Color c, int cur, int goal, int pct) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: ts(12, w: FontWeight.w700)),
            ],
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${cur}g',
                  style: ts(11.5, w: FontWeight.w800),
                ),
                TextSpan(
                  text: ' / ${goal}g target ($pct%)',
                  style: ts(10.5, color: C.sub),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      ProgressBar(value: pct / 100, color: c, height: 8),
    ],
  );

  Widget _ratio(String v) => Expanded(
    child: Column(
      children: [
        Text('Ratio', style: ts(10, color: C.sub)),
        const SizedBox(height: 2),
        Text(v, style: ts(13, w: FontWeight.w800)),
      ],
    ),
  );

  Widget _weightBox(String label, String v, bool hi) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: hi ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: hi ? Border.all(color: C.green.withOpacity(.2)) : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: ts(
              10,
              w: hi ? FontWeight.w800 : FontWeight.w500,
              color: hi ? C.green : C.sub,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(v, style: ts(17, w: FontWeight.w800)),
              const SizedBox(width: 2),
              Text('kg', style: ts(10, color: C.sub)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _week(String w, String v, bool hi) => Column(
    children: [
      Text(
        w,
        style: ts(
          10,
          w: hi ? FontWeight.w800 : FontWeight.w500,
          color: hi ? C.green : C.sub,
        ),
      ),
      Text(
        v,
        style: ts(
          10,
          w: hi ? FontWeight.w800 : FontWeight.w500,
          color: hi ? C.green : C.sub,
        ),
      ),
    ],
  );
}
