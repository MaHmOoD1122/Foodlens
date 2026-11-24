import 'package:flutter/material.dart';

const kGreen = Color(0xFF065F3A);
const kGreen2 = Color(0xFF0A7A4B);
const kGreenLight = Color(0xFFE6F6EC);
const kBorder = Color(0xFFE5E7EB);
const kMuted = Color(0xFF6B7280);
const kRed = Color(0xFFB91C1C);
const kOrange = Color(0xFFEA7A12);
const kBlue = Color(0xFF1D6FB8);

void snack(BuildContext c, String m) => ScaffoldMessenger.of(c)
  ..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
  );

class Tag extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const Tag(
    this.text, {
    super.key,
    this.bg = const Color(0xFFEEF0F6),
    this.fg = const Color(0xFF445066),
  });
  @override
  Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.only(right: 4, bottom: 2),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600),
    ),
  );
}

class FilterChips extends StatelessWidget {
  final List<(String key, String label)> items;
  final String selected;
  final ValueChanged<String> onSelect;
  final Color activeColor;
  const FilterChips({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.activeColor = kGreen,
  });
  @override
  Widget build(BuildContext c) => SizedBox(
    height: 42,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (final (k, l) in items)
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: ChoiceChip(
              label: Text(
                l,
                style: TextStyle(
                  fontSize: 12,
                  color: selected == k ? Colors.white : Colors.black87,
                ),
              ),
              selected: selected == k,
              selectedColor: activeColor,
              showCheckmark: false,
              backgroundColor: Colors.white,
              side: BorderSide(color: selected == k ? activeColor : kBorder),
              shape: const StadiumBorder(),
              onSelected: (_) => onSelect(k),
            ),
          ),
      ],
    ),
  );
}

class Avatar extends StatelessWidget {
  final String text;
  const Avatar(this.text, {super.key});
  @override
  Widget build(BuildContext c) => CircleAvatar(
    radius: 19,
    backgroundColor: kGreenLight,
    child: Text(
      text,
      style: const TextStyle(
        color: kGreen,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    ),
  );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? bg, border;
  final double bw;
  final VoidCallback? onTap;
  const AppCard({
    super.key,
    required this.child,
    this.bg,
    this.border,
    this.bw = 1,
    this.onTap,
  });
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: bg ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border ?? kBorder, width: bw),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    ),
  );
}

class DocHeader extends StatelessWidget {
  final String name;
  const DocHeader(this.name, {super.key});
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    child: Row(
      children: [
        const Avatar('DV'),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name ✔',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Text(
                'Clinical Dietitian • Active Portal',
                style: TextStyle(fontSize: 11, color: kGreen),
              ),
            ],
          ),
        ),
        const Tag('DOC-8849'),
      ],
    ),
  );
}

class MacroBar extends StatelessWidget {
  final List<(double, Color)> parts;
  final double h;
  const MacroBar(this.parts, {super.key, this.h = 6});
  @override
  Widget build(BuildContext c) => ClipRRect(
    borderRadius: BorderRadius.circular(9),
    child: SizedBox(
      height: h,
      child: Row(
        children: [
          for (final (v, col) in parts)
            Expanded(
              flex: (v * 100).round().clamp(1, 10000),
              child: Container(color: col),
            ),
        ],
      ),
    ),
  );
}

InputDecoration fieldDeco(String hint, {String? error}) => InputDecoration(
  hintText: hint,
  errorText: error,
  filled: true,
  fillColor: const Color(0xFFFAFAFA),
  contentPadding: const EdgeInsets.all(12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: kBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: kBorder),
  ),
);

ButtonStyle greenBtn() => ElevatedButton.styleFrom(
  backgroundColor: kGreen,
  foregroundColor: Colors.white,
  minimumSize: const Size.fromHeight(48),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
);
