import 'package:flutter/material.dart';

import '../../theme.dart';

import '../../models.dart';
import 'goal_page.dart';

class AllergiesPage extends StatefulWidget {
  final OnboardingData data;
  const AllergiesPage({super.key, required this.data});
  @override
  State<AllergiesPage> createState() => _AllergiesPageState();
}

class _AllergiesPageState extends State<AllergiesPage> {
  String query = '';
  OnboardingData get d => widget.data;

  bool get hasHighAlert =>
      allergens.any((a) => a.highAlert && d.allergies.contains(a.name));

  void toggle(String name) => setState(() {
    d.allergies.contains(name)
        ? d.allergies.remove(name)
        : d.allergies.add(name);
    d.noAllergies = false;
  });

  void toggleNone() => setState(() {
    d.noAllergies = !d.noAllergies;
    if (d.noAllergies) d.allergies.clear();
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

  @override
  Widget build(BuildContext context) {
    final list = allergens
        .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  const IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: null,
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
                              color: i < 1 ? C.green : C.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('1 / 4', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Any food allergies or intolerances?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NutriLens AI will instantly flag unsafe ingredients during camera scanning.',
                      style: TextStyle(color: C.sub),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (v) => setState(() => query = v),
                      decoration: InputDecoration(
                        hintText: 'Search allergens (e.g. peanuts, gluten...)',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Common Allergens',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${d.allergies.length} Selected',
                          style: const TextStyle(
                            color: C.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.95,
                      children: [
                        for (final a in list)
                          _card(
                            selected: d.allergies.contains(a.name),
                            onTap: () => toggle(a.name),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  a.icon,
                                  color: d.allergies.contains(a.name)
                                      ? C.green
                                      : C.sub,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  a.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  a.note,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: a.highAlert ? C.green : C.sub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _card(
                      onTap: toggleNone,
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('No allergies or dietary restrictions'),
                          ),
                          Checkbox(
                            value: d.noAllergies,
                            onChanged: (_) => toggleNone(),
                          ),
                        ],
                      ),
                    ),
                    if (hasHighAlert) ...[
                      const SizedBox(height: 12),
                      _card(
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: C.orange),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Alert Mode: Strict Warning — scanning will flag any match with red alerts.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: C.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: C.green),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GoalPage(data: d)),
                  ),
                  child: const Text(
                    'Complete Setup',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
