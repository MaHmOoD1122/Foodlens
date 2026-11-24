import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F1B1B4B),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

/// Put your photo at assets/images/avatar.jpg - falls back to an initial.
class Avatar extends StatelessWidget {
  final double size;
  const Avatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      'assets/images/avatar.jpg',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: C.greenTint,
        alignment: Alignment.center,
        child: Text(
          'A',
          style: ts(size * .42, w: FontWeight.w800, color: C.green),
        ),
      ),
    ),
  );
}

class NotifBell extends StatelessWidget {
  const NotifBell({super.key});

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      const Icon(LucideIcons.bell, size: 24, color: C.text),
      Positioned(
        right: 2,
        top: 1,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: C.orange,
            shape: BoxShape.circle,
            border: Border.all(color: C.bg, width: 1.5),
          ),
        ),
      ),
    ],
  );
}

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color tint;
  final double size;
  final double radius;
  const IconBox(
    this.icon, {
    super.key,
    required this.color,
    required this.tint,
    this.size = 40,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Icon(icon, color: color, size: size * .5),
  );
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final double fontSize;
  const Pill(
    this.text, {
    super.key,
    required this.bg,
    required this.fg,
    this.icon,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: ts(fontSize, w: FontWeight.w700, color: fg),
        ),
      ],
    ),
  );
}

class SegToggle extends StatelessWidget {
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  const SegToggle({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: C.lavender,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++)
          GestureDetector(
            onTap: () => onChanged(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: i == index ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: i == index
                    ? const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                items[i],
                style: ts(
                  12,
                  w: FontWeight.w700,
                  color: i == index ? C.text : C.sub,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const ProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeOutCubic,
    builder: (_, v, __) => ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: C.track),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: Container(color: color),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class RingPainter extends CustomPainter {
  final double progress;
  RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset.zero & size;
    final r = Rect.fromCircle(
      center: rect.center,
      radius: size.width / 2 - stroke / 2,
    );
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFE6E9F8);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = C.green;
    canvas.drawArc(r, 0, math.pi * 2, false, track);
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(RingPainter old) => old.progress != progress;
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFC9CCE0)
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), p);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class WeekBarChart extends StatelessWidget {
  final List<double> values;
  final int selected;
  final double goal;
  final double maxValue;
  final double height;
  const WeekBarChart({
    super.key,
    required this.values,
    this.selected = 2,
    this.goal = 1850,
    this.maxValue = 2200,
    this.height = 150,
  });

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    const labelH = 20.0;
    final barArea = height - labelH;
    final lineY = barArea * (1 - goal / maxValue);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      builder: (_, t, __) => SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: lineY,
              child: CustomPaint(
                painter: _DashPainter(),
                size: const Size.fromHeight(1),
              ),
            ),
            Positioned(
              right: 0,
              top: lineY - 14,
              child: Text('Goal 1,850', style: ts(9, color: C.sub)),
            ),
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < values.length; i++)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 22,
                            height: barArea * (values[i] / maxValue) * t,
                            decoration: BoxDecoration(
                              color: i == selected ? C.green : C.greenLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(
                            height: labelH,
                            child: Center(
                              child: Text(
                                _labels[i],
                                style: ts(
                                  10,
                                  w: i == selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: i == selected ? C.text : C.sub,
                                ),
                              ),
                            ),
                          ),
                        ],
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

class MealTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color tint;
  final String title;
  final String subtitle;
  final int kcal;
  const MealTile({
    super.key,
    required this.icon,
    required this.color,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.kcal,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        IconBox(icon, color: color, tint: tint),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ts(13, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: ts(11, color: C.sub)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$kcal', style: ts(16, w: FontWeight.w800)),
            Text('kcal', style: ts(10, color: C.sub)),
          ],
        ),
      ],
    ),
  );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: ts(16, w: FontWeight.w800)),
      if (trailing != null) trailing!,
    ],
  );
}
