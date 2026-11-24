import 'package:flutter/material.dart';

import '../../theme.dart';

import '../../models.dart';
import 'body_profile_page.dart';

class GoalPage extends StatefulWidget {
  final OnboardingData data;
  const GoalPage({super.key, required this.data});
  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  OnboardingData get d => widget.data;

  Widget _card({
    required Widget child,
    bool selected = false,
    VoidCallback? onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? C.greenTint : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? C.green : C.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Row(
                      children: List.generate(
                        4,
                        (i) => Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i < 2 ? C.green : C.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('2 / 4', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What's your main goal?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "We'll personalize your daily calorie target around it.",
                      style: TextStyle(color: C.sub),
                    ),
                    const SizedBox(height: 16),
                    for (final g in goals)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _card(
                          selected: d.goal == g,
                          onTap: () => setState(() => d.goal = g),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: g.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(g.icon, color: g.color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      g.subtitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: C.sub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                d.goal == g
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: d.goal == g ? C.green : C.sub,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      'Activity level',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ActivityLevel>(
                      showSelectedIcon: false,
                      segments: [
                        for (final a in activityLevels)
                          ButtonSegment(value: a, label: Text(a.label)),
                      ],
                      selected: {d.activity},
                      onSelectionChanged: (s) =>
                          setState(() => d.activity = s.first),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: C.navy,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recommended daily target',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${d.targetCalories} kcal',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => d.calorieAdjust -= 50),
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.white54,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => d.calorieAdjust += 50),
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: C.green),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BodyProfilePage(data: d)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
