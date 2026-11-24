import 'package:flutter/material.dart';

import '../../theme.dart';

import '../../models.dart';
import 'connect_doctor_page.dart';

class BodyProfilePage extends StatefulWidget {
  final OnboardingData data;
  const BodyProfilePage({super.key, required this.data});
  @override
  State<BodyProfilePage> createState() => _BodyProfilePageState();
}

class _BodyProfilePageState extends State<BodyProfilePage> {
  OnboardingData get d => widget.data;
  bool useCm = true;
  bool useKg = true;

  static const lbsPerKg = 2.20462;

  String get heightText {
    if (useCm) return '${d.heightCm.round()} cm';
    final totalIn = d.heightCm / 2.54;
    return "${totalIn ~/ 12}' ${(totalIn % 12).round()}\"";
  }

  String get weightText => useKg
      ? '${d.weightKg.toStringAsFixed(1)} kg'
      : '${(d.weightKg * lbsPerKg).toStringAsFixed(1)} lbs';

  void changeWeight(double delta) => setState(() {
    final kgDelta = useKg ? delta : delta / lbsPerKg;
    d.weightKg = (d.weightKg + kgDelta).clamp(20.0, 300.0);
  });

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

  Widget _toggle(
    List<String> options,
    bool first,
    ValueChanged<bool> onChanged,
  ) => ToggleButtons(
    isSelected: [first, !first],
    onPressed: (i) => onChanged(i == 0),
    constraints: const BoxConstraints(minHeight: 30, minWidth: 48),
    borderRadius: BorderRadius.circular(8),
    selectedColor: Colors.white,
    fillColor: C.green,
    children: options
        .map((o) => Text(o, style: const TextStyle(fontSize: 12)))
        .toList(),
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
                              color: i < 3 ? C.green : C.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('3 / 4', style: TextStyle(fontSize: 12)),
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
                      "What's your body profile?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This helps NutriLens calculate your baseline calorie and metabolic needs.',
                      style: TextStyle(color: C.sub),
                    ),
                    const SizedBox(height: 16),

                    // Sex
                    const Text(
                      'Biological Sex',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final s in Sex.values)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _card(
                                selected: d.sex == s,
                                onTap: () => setState(() => d.sex = s),
                                child: Column(
                                  children: [
                                    Icon(switch (s) {
                                      Sex.male => Icons.male,
                                      Sex.female => Icons.female,
                                      Sex.neutral => Icons.transgender,
                                    }, color: d.sex == s ? C.green : C.sub),
                                    Text(
                                      s.name[0].toUpperCase() +
                                          s.name.substring(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Height
                    _card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Height',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              _toggle(
                                ['cm', 'ft/in'],
                                useCm,
                                (v) => setState(() => useCm = v),
                              ),
                            ],
                          ),
                          Text(
                            heightText,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Slider(
                            value: d.heightCm,
                            min: 120,
                            max: 220,
                            activeColor: C.green,
                            onChanged: (v) => setState(() => d.heightCm = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Weight
                    _card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Current Weight',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              _toggle(
                                ['kg', 'lbs'],
                                useKg,
                                (v) => setState(() => useKg = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton.outlined(
                                onPressed: () => changeWeight(-0.5),
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                weightText,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: C.green,
                                ),
                                onPressed: () => changeWeight(0.5),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final delta in const [-2.0, -0.5, 0.5, 2.0])
                                ActionChip(
                                  label: Text(delta > 0 ? '+$delta' : '$delta'),
                                  onPressed: () => changeWeight(delta),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Age
                    _card(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Age',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(
                              () => d.age = (d.age - 1).clamp(10, 100),
                            ),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '${d.age} yrs',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(
                              () => d.age = (d.age + 1).clamp(10, 100),
                            ),
                            icon: const Icon(Icons.add_circle_outline),
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
                    MaterialPageRoute(builder: (_) => DoctorPage(data: d)),
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
