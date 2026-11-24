import 'package:flutter/material.dart';

import '../../theme.dart';

class AllergyAlertScreen extends StatelessWidget {
  const AllergyAlertScreen({
    super.key,
    this.imageAsset = 'assets/images/thai_noodle.png',
    this.dishName = 'Thai Noodle Dish',
    this.matchPercent = 98.4,
    this.allergenTag = 'Peanuts',
    this.allergenNames = 'Peanuts & Tree Nuts',
    this.ingredients = const ['Crushed Peanuts (25g)', 'Peanut Oil'],
    this.mealName = 'Spicy Peanut Noodle Bowl',
    this.mealType = 'Asian Fusion • Main Course',
    this.calories = 580,
    this.protein = 22,
    this.carbs = 64,
    this.fat = 28,
    this.accuracy = 96,
    this.profileNote = 'Severe Peanut & Tree Nut Sensitivity',
    this.onClose,
    this.onFlash,
    this.onCustomize,
    this.onRescan,
    this.onLogAnyway,
  });

  final String imageAsset;
  final String dishName;
  final double matchPercent;
  final String allergenTag;
  final String allergenNames;
  final List<String> ingredients;
  final String mealName;
  final String mealType;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int accuracy;
  final String profileNote;
  final VoidCallback? onClose;
  final VoidCallback? onFlash;
  final VoidCallback? onCustomize;
  final VoidCallback? onRescan;
  final VoidCallback? onLogAnyway;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Hero(
              imageAsset: imageAsset,
              dishName: dishName,
              matchPercent: matchPercent,
              allergenTag: allergenTag,
              onClose: onClose ?? () => Navigator.maybePop(context),
              onFlash: onFlash,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  _AlertCard(
                    allergenNames: allergenNames,
                    ingredients: ingredients,
                  ),
                  const SizedBox(height: 14),
                  _SummaryCard(
                    mealName: mealName,
                    mealType: mealType,
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    accuracy: accuracy,
                  ),
                  const SizedBox(height: 14),
                  _ActionButton(
                    label: 'Customize Ingredients (Remove Allergen)',
                    icon: Icons.tune_rounded,
                    bg: C.brand,
                    fg: Colors.white,
                    height: 52,
                    onTap: onCustomize,
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: 'Discard & Rescan',
                    icon: Icons.refresh_rounded,
                    bg: C.lavender,
                    fg: C.text,
                    onTap: onRescan,
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: 'Log Anyway (High Risk)',
                    icon: Icons.warning_amber_rounded,
                    bg: C.redTint,
                    fg: C.redDark,
                    onTap: onLogAnyway,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'NutriLens Guard • Profile: $profileNote',
                    textAlign: TextAlign.center,
                    style: ts(11, color: C.subDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Hero ─────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({
    required this.imageAsset,
    required this.dishName,
    required this.matchPercent,
    required this.allergenTag,
    required this.onClose,
    this.onFlash,
  });

  final String imageAsset;
  final String dishName;
  final double matchPercent;
  final String allergenTag;
  final VoidCallback onClose;
  final VoidCallback? onFlash;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: C.navy),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x73000000),
                  Color(0x00000000),
                  Color(0xBF000000),
                ],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  top: 8,
                  child: _CircleBtn(icon: Icons.close_rounded, onTap: onClose),
                ),
                Positioned(
                  right: 16,
                  top: 8,
                  child: _CircleBtn(icon: Icons.bolt_rounded, onTap: onFlash),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: C.neon,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AI Scan Complete',
                                style: ts(
                                  11,
                                  w: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: C.redStrong,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            allergenTag,
                            style: ts(
                              11,
                              w: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Detection frame
          Positioned(
            left: 28,
            right: 28,
            top: 120,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: C.red, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TARGET RECOGNITION',
                      style: ts(
                        10,
                        w: FontWeight.w700,
                        color: C.border,
                        ls: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dishName,
                      style: ts(20, w: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: C.neon,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$matchPercent% Match',
                        style: ts(12, w: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 4,
            child: ColoredBox(color: C.orangeBar),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ───────────────────────── Alert card ─────────────────────────

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.allergenNames, required this.ingredients});
  final String allergenNames;
  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -4),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: C.redTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: C.redDark,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allergen Detected!',
                        style: ts(18, w: FontWeight.w800, color: C.redDark),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: C.redStrong,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'HIGH RISK',
                          style: ts(
                            10,
                            w: FontWeight.w800,
                            color: Colors.white,
                            ls: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          style: ts(13, color: C.subDark, height: 1.45),
                          children: [
                            const TextSpan(text: 'Contains '),
                            TextSpan(
                              text: allergenNames,
                              style: ts(
                                13,
                                w: FontWeight.w700,
                                color: C.redDark,
                              ),
                            ),
                            const TextSpan(
                              text: ' — matches your allergy profile.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: C.redSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.redBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identified Critical Ingredients:',
                    style: ts(11, w: FontWeight.w700, color: C.redDark),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final i in ingredients) _IngredientChip(label: i),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: C.lavender,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: C.redDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Consuming this meal may cause an allergic reaction. '
                      'Please verify with preparation staff or substitute ingredients.',
                      style: ts(12, color: C.subDark, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: C.redBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: C.redStrong,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: ts(12, w: FontWeight.w600, color: C.redDark),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Summary card ─────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.mealName,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.accuracy,
  });

  final String mealName;
  final String mealType;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int accuracy;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DETECTED MEAL SUMMARY',
                style: ts(11, w: FontWeight.w800, color: C.brand, ls: 0.6),
              ),
              Text(
                'Estimated Accuracy: $accuracy%',
                style: ts(11, color: C.subDark),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mealName, style: ts(18, w: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(mealType, style: ts(12, color: C.subDark)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$calories',
                    style: ts(30, w: FontWeight.w800, height: 1),
                  ),
                  Text('kcal', style: ts(11, color: C.subDark)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MacroBox(label: 'Protein', value: '${protein}g'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroBox(label: 'Carbs', value: '${carbs}g'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroBox(
                  label: 'Fat (Allergen)',
                  value: '${fat}g',
                  danger: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroBox extends StatelessWidget {
  const _MacroBox({
    required this.label,
    required this.value,
    this.danger = false,
  });
  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: danger ? C.redTint : C.bg,
        borderRadius: BorderRadius.circular(12),
        border: danger ? Border.all(color: C.redBorder) : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ts(
              11,
              w: danger ? FontWeight.w600 : FontWeight.w500,
              color: danger ? C.redDark : C.subDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: ts(
              16,
              w: FontWeight.w800,
              color: danger ? C.redDark : C.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Shared bits ─────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: C.cardBorder),
        boxShadow: [
          BoxShadow(
            color: C.text.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    this.height = 48,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: fg),
        label: Text(
          label,
          style: ts(14, w: FontWeight.w700, color: fg),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height > 48 ? 16 : 14),
          ),
        ),
      ),
    );
  }
}
