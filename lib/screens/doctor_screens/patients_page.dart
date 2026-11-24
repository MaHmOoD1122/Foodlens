import 'package:flutter/material.dart';

import '../../common.dart';
import '../../state.dart';
import '../../theme.dart';
import 'targets_sheet.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});
  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  String filter = 'all', q = '';

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (_, __) {
      final all = app.patients;
      int cnt(String f) => f == 'allergy'
          ? all.where((p) => p.allergy).length
          : f == 'over'
          ? all.where((p) => p.over).length
          : all.length;
      final list = all.where((p) {
        final okF =
            filter == 'all' ||
            (filter == 'allergy' && p.allergy) ||
            (filter == 'over' && p.over);
        final okQ = '${p.name} ${p.id}'.toLowerCase().contains(q.toLowerCase());
        return okF && okQ;
      }).toList();
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          DocHeader(app.doctorName),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patients Directory', style: ts(19, w: FontWeight.w800)),
                Text(
                  'Real-time dietary monitoring & allergen telemetry',
                  style: ts(12, color: C.sub),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _stat('Total', '${all.length}', 'Active Rx', C.text),
                    _stat(
                      'Alerts',
                      '${app.openAlerts.length}',
                      'Immediate',
                      C.red,
                      border: C.redAlertBorder,
                    ),
                    _stat('Adherence', '${app.avgAdherence}%', '', C.green),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: fieldDeco('Search patient by name or ID...')
                      .copyWith(prefixIcon: const Icon(Icons.search, size: 20)),
                  onChanged: (v) => setState(() => q = v),
                ),
                const SizedBox(height: 6),
                FilterChips(
                  selected: filter,
                  onSelect: (v) => setState(() => filter = v),
                  items: [
                    ('all', 'All (${cnt('all')})'),
                    ('allergy', 'Allergy Risk (${cnt('allergy')})'),
                    ('over', 'Over-calorie (${cnt('over')})'),
                  ],
                ),
                const SizedBox(height: 8),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'No patients match.',
                        style: ts(14, color: C.sub),
                      ),
                    ),
                  ),
                for (final p in list) _card(context, p),
              ],
            ),
          ),
        ],
      );
    },
  );

  Widget _stat(
    String a,
    String b,
    String c,
    Color col, {
    Color border = C.border,
  }) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(a, style: ts(11, color: C.sub)),
          Text(
            b,
            style: ts(20, w: FontWeight.w800, color: col),
          ),
          Text(c, style: ts(10, color: C.sub)),
        ],
      ),
    ),
  );

  Widget _card(BuildContext c, Patient p) {
    final crit = app.hasCritical(p.id);
    final pct = (p.consumed / p.ceiling).clamp(0.0, 1.0);
    return AppCard(
      bg: crit ? C.redAlertSurface : null,
      border: crit ? C.red : null,
      bw: crit ? 2 : 1,
      onTap: () => showTargetsSheet(c, p.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (crit)
            Text(
              '⚠ CRITICAL ALLERGY ALERT',
              style: ts(11, w: FontWeight.w800, color: C.red),
            ),
          Row(
            children: [
              Avatar(p.initials),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p.name}  ${p.id}',
                      style: ts(13, w: FontWeight.w700),
                    ),
                    Text('${p.age} yrs, ${p.sex}', style: ts(11, color: C.sub)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: C.sub),
            ],
          ),
          const SizedBox(height: 8),
          Tag(
            '${p.adh}% Adherence • ${p.status}',
            bg: p.over ? C.amberTint : C.greenLight,
            fg: p.over ? C.amberDark : C.green,
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: C.track,
              color: p.over ? C.orange : C.green,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${p.consumed} / ${p.ceiling} kcal',
              style: ts(11, color: C.sub),
            ),
          ),
          Text(
            p.allergy ? '🛡 ${p.allergyTxt}' : p.plan,
            style: ts(12, color: C.sub),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Last scan: ${p.last}',
                  style: ts(11, color: C.sub),
                ),
              ),
              TextButton(
                onPressed: () => showTargetsSheet(c, p.id),
                child: const Text('Edit targets'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
