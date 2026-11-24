import 'package:flutter/material.dart';

import '../../theme.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({
    super.key,
    this.imageAsset = 'assets/images/grilled_salmon_salad.png',
    this.dishName = 'Grilled Salmon Salad',
    this.matchPercent = 92,
    this.calories = 420,
    this.portionGrams = 320,
    this.proteinG = 35,
    this.carbsG = 12,
    this.fatsG = 38,
    this.insight =
        'This meal is high in protein and healthy fats. '
        'Great for muscle recovery and heart health.',
    this.onBack,
    this.onRetake,
    this.onLog,
    this.onShare,
  });

  final String imageAsset;
  final String dishName;
  final int matchPercent;
  final int calories;
  final int portionGrams;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final String insight;
  final VoidCallback? onBack;
  final VoidCallback? onRetake;
  final VoidCallback? onLog;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final total = (proteinG + carbsG + fatsG).toDouble();
    final pPct = total == 0 ? 0.0 : proteinG / total;
    final cPct = total == 0 ? 0.0 : carbsG / total;
    final fPct = total == 0 ? 0.0 : fatsG / total;

    // ارتفاع ديناميكي للصورة يناسب أي شاشة
    final screenH = MediaQuery.sizeOf(context).height;
    final heroH = (screenH * 0.35).clamp(200.0, 320.0);

    return Scaffold(
      backgroundColor: Colors.white,
      // زرار الـ Log في مكانه الطبيعي في الـ Scaffold عشان ميعملش Overflow أبداً
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: onLog,
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                  ),
                  label: Text(
                    'Log to Diary',
                    style: ts(14, w: FontWeight.w700, color: Colors.white),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: C.brand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 52,
              height: 52,
              child: IconButton.filled(
                onPressed: onShare,
                tooltip: 'Share',
                icon: const Icon(Icons.share_outlined, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: C.lavender,
                  foregroundColor: C.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Hero Image + Top Buttons
            SizedBox(
              height: heroH,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: C.lavender,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 48,
                        color: C.subDark.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CircleBtn(
                              icon: Icons.arrow_back_ios_new_rounded,
                              label: 'Back',
                              onTap:
                                  onBack ?? () => Navigator.maybePop(context),
                            ),
                            _CircleBtn(
                              icon: Icons.refresh_rounded,
                              label: 'Retake photo',
                              onTap: onRetake,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Sheet متداخل مع الصورة بـ Transform
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: C.text.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: C.inputBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Header(name: dishName, match: matchPercent),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Calories',
                            value: '$calories',
                            unit: 'kcal',
                            icon: Icons.local_fire_department_rounded,
                            bg: C.blueTint,
                            iconBg: const Color(0xFFCFE2FA),
                            accent: C.blueDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            label: 'Portion',
                            value: '$portionGrams',
                            unit: 'grams',
                            icon: Icons.hourglass_bottom_rounded,
                            bg: C.orangeTint,
                            iconBg: const Color(0xFFFFDCC6),
                            accent: C.orangeDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _MacroCard(
                      rows: [
                        _MacroRow('Protein (${proteinG}g)', pPct, C.orangeBar),
                        _MacroRow('Carbs (${carbsG}g)', cPct, C.orangeLightBar),
                        _MacroRow('Fats (${fatsG}g)', fPct, C.blueBar),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _InsightBox(text: insight),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Pieces ─────────────────────────

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: label,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.match});
  final String name;
  final int match;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: ts(20, w: FontWeight.w800)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: C.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Analysis complete • High confidence',
                      style: ts(12, color: C.subDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: C.greenBadge,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$match% Match',
            style: ts(11, w: FontWeight.w700, color: C.greenDeep),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.bg,
    required this.iconBg,
    required this.accent,
  });
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color bg;
  final Color iconBg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: ts(12, w: FontWeight.w600, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: ts(26, w: FontWeight.w800)),
              const SizedBox(width: 4),
              Text(unit, style: ts(12, color: C.subDark)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRow {
  const _MacroRow(this.label, this.fraction, this.color);
  final String label;
  final double fraction;
  final Color color;
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({required this.rows});
  final List<_MacroRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Macronutrients', style: ts(14, w: FontWeight.w800)),
              Text('Calculated macros', style: ts(11, color: C.subDark)),
            ],
          ),
          for (final r in rows) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: r.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(r.label, style: ts(12, w: FontWeight.w600)),
                  ],
                ),
                Text(
                  '${(r.fraction * 100).round()}%',
                  style: ts(12, w: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: r.fraction,
                minHeight: 6,
                backgroundColor: C.track,
                valueColor: AlwaysStoppedAnimation(r.color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightBox extends StatelessWidget {
  const _InsightBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.greenTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.greenBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: C.brand,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: ts(12, color: C.text, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
