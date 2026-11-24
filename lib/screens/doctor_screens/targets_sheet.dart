import 'package:flutter/material.dart';

import '../../common.dart';
import '../../state.dart';
import '../../theme.dart';

void showTargetsSheet(BuildContext context, String patientId) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TargetsSheet(patientId: patientId),
    );

class TargetsSheet extends StatefulWidget {
  final String patientId;
  const TargetsSheet({super.key, required this.patientId});
  @override
  State<TargetsSheet> createState() => _TargetsSheetState();
}

class _TargetsSheetState extends State<TargetsSheet> {
  late Patient p = app.patient(widget.patientId);
  late int ceiling = p.ceiling,
      protein = p.protein,
      carbs = p.carbs,
      fat = p.fat;
  late bool gate = p.gate;
  late final note = TextEditingController(text: p.note);

  int get total => protein * 4 + carbs * 4 + fat * 9;
  int get diff => total - ceiling;
  bool get ok => diff.abs() <= 30;
  int pct(int kcal) => total == 0 ? 0 : (kcal / total * 100).round();

  void publish() {
    app.publishTargets(
      p.id,
      ceiling: ceiling,
      protein: protein,
      carbs: carbs,
      fat: fat,
      note: note.text,
      gate: gate,
    );
    Navigator.pop(context);
    snack(context, '✓ Published to ${p.name}\'s app');
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Tag(
                        'Clinician Portal',
                        bg: C.greenLight,
                        fg: C.green,
                      ),
                      Text('ID: #${p.id}', style: ts(11, color: C.sub)),
                    ],
                  ),
                  Text(
                    'Update Calorie & Macro Targets',
                    style: ts(17, w: FontWeight.w800),
                  ),
                  Text(
                    'Prescribing for ${p.name} (${p.plan})',
                    style: ts(12, color: C.sub),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          bg: C.surfaceSoft,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Daily Calorie Ceiling',
                      style: ts(14, w: FontWeight.w700),
                    ),
                  ),
                  _round(
                    Icons.remove,
                    () => setState(
                      () => ceiling = (ceiling - 50).clamp(1200, 3500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$ceiling',
                      style: ts(26, w: FontWeight.w800, color: C.green),
                    ),
                  ),
                  Text('kcal', style: ts(11, color: C.sub)),
                  _round(
                    Icons.add,
                    () => setState(
                      () => ceiling = (ceiling + 50).clamp(1200, 3500),
                    ),
                  ),
                ],
              ),
              Slider(
                value: ceiling.toDouble(),
                min: 1200,
                max: 3500,
                divisions: 46,
                activeColor: C.green,
                onChanged: (v) => setState(() => ceiling = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1,200', style: ts(11, color: C.sub)),
                  Text('Current: ${p.ceiling}', style: ts(11, color: C.sub)),
                  Text('3,500', style: ts(11, color: C.sub)),
                ],
              ),
              const SizedBox(height: 8),
              _banner(
                ceiling < p.ceiling
                    ? 'Creates a ${p.ceiling - ceiling} kcal deficit vs current plan.'
                    : ceiling > p.ceiling
                    ? 'Raises ceiling by ${ceiling - p.ceiling} kcal.'
                    : 'No change from current plan.',
                true,
              ),
            ],
          ),
        ),
        Text(
          'Clinical Macronutrient Breakdown',
          style: ts(15, w: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        MacroBar(
          [
            (protein * 4.0, C.green),
            (carbs * 4.0, C.orange),
            (fat * 9.0, C.blue),
          ].map((e) => (e.$1 + 0.01, e.$2)).toList(),
          h: 7,
        ),
        const SizedBox(height: 10),
        _macro(
          'Protein Target',
          'Lean preservation',
          protein,
          4,
          C.green,
          (v) => setState(() => protein = v),
        ),
        _macro(
          'Carbohydrates Target',
          'Glycogen recovery & fiber',
          carbs,
          4,
          C.orange,
          (v) => setState(() => carbs = v),
        ),
        _macro(
          'Healthy Lipids Target',
          'Endocrine & hormonal baseline',
          fat,
          9,
          C.blue,
          (v) => setState(() => fat = v),
        ),
        _banner(
          '${ok ? '✔' : '⚠'} Total Calorie Match: macros sum to $total kcal (${ok ? 'Calibrated' : '${diff > 0 ? '+' : ''}$diff vs ceiling'})',
          ok,
        ),
        const SizedBox(height: 12),
        Text(
          'Clinical Notes & Next Scan Directive',
          style: ts(12, w: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: note,
          maxLines: 3,
          decoration: fieldDeco('Visible in Patient Lens AI'),
        ),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Scanner Meal Gate',
                      style: ts(12, w: FontWeight.w700),
                    ),
                    Text(
                      'Auto-flag meal if protein is below 25g per scan',
                      style: ts(11, color: C.sub),
                    ),
                  ],
                ),
              ),
              Switch(
                value: gate,
                activeColor: C.green,
                onChanged: (v) => setState(() => gate = v),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: publish,
                style: greenBtn(),
                child: const Text('Publish to Patient App'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _round(IconData i, VoidCallback f) => InkWell(
    onTap: f,
    customBorder: const CircleBorder(),
    child: Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: C.greenCircleBg,
        shape: BoxShape.circle,
      ),
      child: Icon(i, size: 16, color: C.green),
    ),
  );

  Widget _banner(String t, bool good) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: good ? C.greenLight : C.amberTint,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      t,
      style: ts(12, w: FontWeight.w600, color: good ? C.green : C.amberDark),
    ),
  );

  Widget _macro(
    String t,
    String sub,
    int g,
    int kPerG,
    Color col,
    ValueChanged<int> set,
  ) => AppCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '● $t',
                style: ts(12, w: FontWeight.w700, color: col),
              ),
              Text(sub, style: ts(11, color: C.sub)),
              Text('${g * kPerG} kcal • ${pct(g * kPerG)}%', style: ts(11)),
            ],
          ),
        ),
        _round(Icons.remove, () => set((g - 5).clamp(0, 999))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$g g', style: ts(16, w: FontWeight.w800)),
        ),
        _round(Icons.add, () => set((g + 5).clamp(0, 999))),
      ],
    ),
  );
}
