import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme.dart';

class FoodItem {
  final String name;
  final String portion;
  final int kcal;
  final IconData icon;
  const FoodItem(this.name, this.portion, this.kcal, this.icon);
}

const _foods = <FoodItem>[
  FoodItem('Grilled Salmon Salad', '320g', 420, LucideIcons.leaf),
  FoodItem('Oatmeal with berries', '280g', 340, LucideIcons.croissant),
  FoodItem('Apple & almonds', '150g', 210, LucideIcons.apple),
  FoodItem('Margherita pizza', '260g', 690, LucideIcons.pizza),
  FoodItem('Chicken rice bowl', '300g', 560, LucideIcons.soup),
  FoodItem('Greek yogurt', '170g', 130, LucideIcons.cupSoda),
  FoodItem('Scrambled eggs', '120g', 220, LucideIcons.egg),
  FoodItem('Avocado toast', '160g', 310, LucideIcons.sandwich),
  FoodItem('Caesar salad', '250g', 360, LucideIcons.salad),
  FoodItem('Beef burger', '230g', 640, LucideIcons.beef),
  FoodItem('Banana', '118g', 105, LucideIcons.banana),
  FoodItem('Mixed nuts', '30g', 180, LucideIcons.nut),
  FoodItem('Whole wheat pasta', '240g', 420, LucideIcons.wheat),
  FoodItem('Lentil soup', '300g', 230, LucideIcons.soup),
  FoodItem('Protein shake', '330ml', 160, LucideIcons.cupSoda),
  FoodItem('Chocolate cookie', '40g', 190, LucideIcons.cookie),
];

class FoodSearchSheet extends StatefulWidget {
  const FoodSearchSheet({super.key});

  @override
  State<FoodSearchSheet> createState() => _FoodSearchSheetState();
}

class _FoodSearchSheetState extends State<FoodSearchSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final results = _foods
        .where((f) => f.name.toLowerCase().contains(_q.trim().toLowerCase()))
        .toList();
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: kb),
      child: Container(
        height: MediaQuery.sizeOf(context).height * .8,
        decoration: const BoxDecoration(
          color: C.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: C.track,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Search food',
                      style: ts(18, w: FontWeight.w800),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(LucideIcons.x, size: 22, color: C.sub),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _q = v),
                style: ts(14),
                cursorColor: C.green,
                decoration: InputDecoration(
                  hintText: 'Search meals, ingredients...',
                  hintStyle: ts(13, color: C.sub),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    size: 18,
                    color: C.sub,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: C.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: C.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: C.green, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        'No results for "$_q"',
                        style: ts(13, color: C.sub),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final f = results[i];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(f),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: C.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: C.greenTint,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(f.icon, size: 20, color: C.green),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        f.name,
                                        style: ts(13, w: FontWeight.w700),
                                      ),
                                      Text(
                                        f.portion,
                                        style: ts(11, color: C.sub),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${f.kcal}',
                                  style: ts(15, w: FontWeight.w800),
                                ),
                                const SizedBox(width: 3),
                                Text('kcal', style: ts(10, color: C.sub)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
