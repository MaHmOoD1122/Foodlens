import 'package:flutter/material.dart';

import '../../common.dart';
import '../../state.dart';
import '../../theme.dart';
import 'targets_sheet.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (_, __) {
      final open = app.openAlerts;
      int cnt(String t) => open.where((a) => a.type == t).length;
      final list = open
          .where((a) => filter == 'all' || a.type == filter)
          .toList();
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          DocHeader(app.doctorName),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clinical Alerts',
                            style: ts(19, w: FontWeight.w800),
                          ),
                          Text(
                            'Real-time AI scan warnings & cross-contamination flags',
                            style: ts(12, color: C.sub),
                          ),
                        ],
                      ),
                    ),
                    Tag(
                      '● ${open.length} Unresolved',
                      bg: C.redTint,
                      fg: C.red,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FilterChips(
                  selected: filter,
                  onSelect: (v) => setState(() => filter = v),
                  items: [
                    ('all', 'All (${open.length})'),
                    ('allergy', 'Severe Allergies (${cnt('allergy')})'),
                    ('calorie', 'Calorie Spikes (${cnt('calorie')})'),
                  ],
                ),
                const SizedBox(height: 8),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        '🎉 No unresolved alerts.',
                        style: ts(14, color: C.sub),
                      ),
                    ),
                  ),
                for (final a in list) _card(context, a),
              ],
            ),
          ),
        ],
      );
    },
  );

  Widget _card(BuildContext c, AlertItem a) {
    final p = app.patient(a.pid);
    final al = a.type == 'allergy';
    final col = al ? C.red : C.amberDark;
    return AppCard(
      bg: al ? C.redAlertSurface : C.amberSurface,
      border: al ? C.redAlertBorder : C.amberBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${al ? '🚨' : '🔥'} ${a.title}',
                  style: ts(11, w: FontWeight.w800, color: col),
                ),
              ),
              Text(a.time, style: ts(11, color: C.sub)),
            ],
          ),
          const SizedBox(height: 8),
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
                    Text(
                      '${p.age} yrs • ${p.sex}',
                      style: ts(11, color: C.sub),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (a.item != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text.rich(
                TextSpan(
                  text: 'Scanned item: ',
                  style: ts(12, color: C.sub),
                  children: [
                    TextSpan(
                      text: a.item,
                      style: ts(12, w: FontWeight.w700, color: C.text),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: al ? C.redTint : C.amberTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              a.detail,
              style: ts(12, w: FontWeight.w600, color: col),
            ),
          ),
          if (al) ...[
            ElevatedButton.icon(
              onPressed: () => snack(c, 'Opening scan photo...'),
              icon: const Icon(Icons.image_outlined, size: 18),
              label: const Text('Review Scan Photo'),
              style: greenBtn(),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => snack(c, 'Calling ${p.name}...'),
              icon: const Icon(Icons.call_outlined, size: 18),
              label: const Text('Call / Message Patient'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => showTargetsSheet(c, p.id),
                    child: const Text('Adjust Target'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => snack(c, 'Note sent to ${p.name}'),
                    child: const Text('Send Note'),
                  ),
                ),
              ],
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                app.resolve(a.id);
                snack(c, 'Alert resolved');
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Mark resolved'),
            ),
          ),
        ],
      ),
    );
  }
}
