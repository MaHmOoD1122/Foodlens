import 'package:flutter/material.dart';

import '../../common.dart';
import '../../state.dart';
import '../../theme.dart';

class ProtocolsPage extends StatefulWidget {
  const ProtocolsPage({super.key});
  @override
  State<ProtocolsPage> createState() => _ProtocolsPageState();
}

class _ProtocolsPageState extends State<ProtocolsPage> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (_, __) {
      final list = app.protocols
          .where((p) => filter == 'all' || p.cat == filter)
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
                            'Dietary Protocols',
                            style: ts(20, w: FontWeight.w800),
                          ),
                          Text(
                            'Prescribed nutrition frameworks & templates',
                            style: ts(12, color: C.sub),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _newProtocol(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Protocol'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.green,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilterChips(
                  selected: filter,
                  onSelect: (v) => setState(() => filter = v),
                  items: [
                    ('all', 'All (${app.protocols.length})'),
                    ('Weight Loss', 'Weight Loss'),
                    ('Hypertrophy', 'Hypertrophy'),
                    ('Diabetes', 'Diabetes'),
                  ],
                ),
                const SizedBox(height: 8),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Text('No protocols.', style: ts(14, color: C.sub)),
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

  Widget _card(BuildContext c, Protocol p) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                children: [
                  Tag('👥 ${p.assigned} Assigned Patients'),
                  Tag(p.badge, bg: C.amberTint, fg: C.amberDark),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${p.kcal}',
                  style: ts(20, w: FontWeight.w800, color: C.green),
                ),
                Text('kcal / day', style: ts(10, color: C.sub)),
              ],
            ),
          ],
        ),
        Text(p.name, style: ts(15, w: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(p.desc, style: ts(12, color: C.sub)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: C.surfaceSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Macronutrient Breakdown', style: ts(11, color: C.sub)),
                  Text(
                    'Total: ${p.grams('carb') + p.grams('prot') + p.grams('fat')}g',
                    style: ts(11, w: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              MacroBar([
                (p.carb / 100, C.blue),
                (p.prot / 100, C.green),
                (p.fat / 100, C.orange),
              ]),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${p.carb}% Carb ${p.grams('carb')}g',
                    style: ts(11, w: FontWeight.w600, color: C.blue),
                  ),
                  Text(
                    '${p.prot}% Protein ${p.grams('prot')}g',
                    style: ts(11, w: FontWeight.w600, color: C.green),
                  ),
                  Text(
                    '${p.fat}% Fat ${p.grams('fat')}g',
                    style: ts(11, w: FontWeight.w600, color: C.orange),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (p.allergens.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              children: [
                for (final a in p.allergens)
                  Tag('🚫 $a', bg: C.redTint, fg: C.red),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _assign(c, p),
                icon: const Icon(Icons.person_add_alt, size: 18),
                label: const Text('Assign to Patient'),
                style: greenBtn(),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => showDialog(
                context: c,
                builder: (_) => AlertDialog(
                  title: const Text('Delete protocol?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        app.deleteProtocol(p.id);
                        Navigator.pop(c);
                      },
                      child: Text('Delete', style: ts(14, color: C.red)),
                    ),
                  ],
                ),
              ),
              style: OutlinedButton.styleFrom(minimumSize: const Size(46, 48)),
              child: const Icon(Icons.delete_outline, size: 20),
            ),
          ],
        ),
      ],
    ),
  );

  void _assign(BuildContext c, Protocol p) => showModalBottomSheet(
    context: c,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          Text('Assign “${p.name}”', style: ts(16, w: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final pt in app.patients)
            ListTile(
              leading: Avatar(pt.initials),
              title: Text(pt.name, style: ts(13, w: FontWeight.w700)),
              subtitle: Text(
                'Current: ${pt.plan}',
                style: ts(11, color: C.sub),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                app.assign(p.id, pt.id);
                Navigator.pop(c);
                snack(c, 'Assigned to ${pt.name}');
              },
            ),
        ],
      ),
    ),
  );

  void _newProtocol(BuildContext c) {
    final name = TextEditingController(),
        desc = TextEditingController(),
        kcal = TextEditingController(text: '2000');
    final cb = TextEditingController(text: '45'),
        pr = TextEditingController(text: '30'),
        ft = TextEditingController(text: '25');
    String cat = 'Weight Loss';
    String? err;
    showModalBottomSheet(
      context: c,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Protocol', style: ts(16, w: FontWeight.w800)),
                const SizedBox(height: 10),
                TextField(
                  controller: name,
                  decoration: fieldDeco('Protocol name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: kcal,
                  keyboardType: TextInputType.number,
                  decoration: fieldDeco('Daily kcal'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: cat,
                  decoration: fieldDeco('Category'),
                  items: [
                    for (final x in ['Weight Loss', 'Hypertrophy', 'Diabetes'])
                      DropdownMenuItem(value: x, child: Text(x)),
                  ],
                  onChanged: (v) => set(() => cat = v!),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cb,
                        keyboardType: TextInputType.number,
                        decoration: fieldDeco('Carb %'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: pr,
                        keyboardType: TextInputType.number,
                        decoration: fieldDeco('Protein %'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: ft,
                        keyboardType: TextInputType.number,
                        decoration: fieldDeco('Fat %'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: desc,
                  maxLines: 2,
                  decoration: fieldDeco('Description'),
                ),
                if (err != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(err!, style: ts(12, color: C.red)),
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: greenBtn(),
                  onPressed: () {
                    final a = int.tryParse(cb.text) ?? 0,
                        b = int.tryParse(pr.text) ?? 0,
                        d = int.tryParse(ft.text) ?? 0;
                    if (name.text.trim().isEmpty)
                      return set(() => err = 'Name is required');
                    if (a + b + d != 100)
                      return set(() => err = 'Macros must sum to 100%');
                    app.addProtocol(
                      Protocol(
                        id: DateTime.now().millisecondsSinceEpoch,
                        name: name.text.trim(),
                        kcal: int.tryParse(kcal.text) ?? 2000,
                        carb: a,
                        prot: b,
                        fat: d,
                        cat: cat,
                        badge: 'Custom',
                        desc: desc.text.isEmpty ? 'Custom protocol' : desc.text,
                      ),
                    );
                    Navigator.pop(ctx);
                    snack(c, 'Protocol created');
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
