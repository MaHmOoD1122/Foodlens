import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/local_auth_service.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../auth/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _reminders = true;

  @override
  Widget build(BuildContext context) {
    final user = LocalAuthService.instance.currentUser;
    final fullName = user?.fullName ?? 'Alex Johnson';
    final age = user?.age ?? 28;
    final heightCm = user?.heightCm.round() ?? 178;
    final weightKg = user?.weightKg.toStringAsFixed(1) ?? '74.5';
    final bmiVal = user?.bmi.toStringAsFixed(1) ?? '23.5';
    final bmiLabel = user?.bmiLabel ?? 'Healthy';
    final targetCal = user?.targetCalories ?? 1850;
    final proteinTarget = user?.proteinTargetG ?? 139;
    final carbsTarget = user?.carbsTargetG ?? 208;
    final fatsTarget = user?.fatsTargetG ?? 51;
    final allergies = user?.allergies ?? const <String>[];
    final hasAllergies = !(user?.noAllergies ?? true) && allergies.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile', style: ts(22, w: FontWeight.w800)),
              const Icon(LucideIcons.settings, color: C.sub, size: 22),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: C.green, width: 2),
                      ),
                      child: const Avatar(size: 80),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: C.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          LucideIcons.camera,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(fullName, style: ts(18, w: FontWeight.w800)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _metric('Age', '$age', 'yrs'),
                    _metric('Height', '$heightCm', 'cm'),
                    _metric('Weight', weightKg, 'kg'),
                    _metric(
                      'BMI',
                      bmiVal,
                      bmiLabel,
                      green: bmiLabel == 'Healthy',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const IconBox(
                      LucideIcons.flame,
                      color: C.orange,
                      tint: C.orangeTint,
                      size: 36,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nutrition Targets',
                        style: ts(14, w: FontWeight.w800),
                      ),
                    ),
                    const Icon(LucideIcons.pencil, size: 18, color: C.green),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: C.lavender,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Calorie Target',
                        style: ts(12, w: FontWeight.w600, color: C.sub),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$targetCal',
                            style: ts(22, w: FontWeight.w800, color: C.green),
                          ),
                          const SizedBox(width: 4),
                          Text('kcal / day', style: ts(10, color: C.sub)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Macro Distribution', style: ts(11, color: C.sub)),
                    Text(
                      '100% Calibrated',
                      style: ts(11, w: FontWeight.w800, color: C.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(flex: 30, child: Container(color: C.green)),
                        Expanded(flex: 45, child: Container(color: C.orange)),
                        Expanded(flex: 25, child: Container(color: C.blue)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _legend(C.green, '30% Protein', '${proteinTarget}g target'),
                    _legend(C.orange, '45% Carbs', '${carbsTarget}g target'),
                    _legend(C.blue, '25% Fats', '${fatsTarget}g target'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const IconBox(
                      LucideIcons.shieldAlert,
                      color: C.red,
                      tint: C.redTint,
                      size: 36,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Allergen Guard',
                        style: ts(14, w: FontWeight.w800),
                      ),
                    ),
                    Text(
                      'Manage',
                      style: ts(12, w: FontWeight.w700, color: C.green),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasAllergies ? C.redTint : C.greenTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasAllergies
                          ? C.red.withOpacity(.2)
                          : C.green.withOpacity(.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasAllergies
                            ? LucideIcons.triangleAlert
                            : LucideIcons.shieldCheck,
                        color: hasAllergies ? C.red : C.green,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasAllergies
                                  ? allergies.join(', ')
                                  : 'No Allergies Selected',
                              style: ts(
                                12,
                                w: FontWeight.w800,
                                color: hasAllergies ? C.red : C.green,
                              ),
                            ),
                            Text(
                              hasAllergies
                                  ? 'Strict Scan Alert Active'
                                  : 'Safe for all scanned items',
                              style: ts(
                                10,
                                color: hasAllergies
                                    ? C.red.withOpacity(.8)
                                    : C.sub,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Pill(
                        hasAllergies ? 'Active' : 'Clear',
                        bg: hasAllergies ? C.red : C.green,
                        fg: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.circleCheck,
                      color: C.green,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user?.doctorName != null
                            ? 'Synced with ${user!.doctorName}'
                            : 'AI Food Scanner alerts automatically in viewfinder',
                        style: ts(10.5, color: C.sub),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected Devices & AI',
                  style: ts(14, w: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const IconBox(
                      LucideIcons.heartPulse,
                      color: C.blue,
                      tint: C.blueTint,
                      size: 34,
                      radius: 17,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apple Health',
                            style: ts(12, w: FontWeight.w800),
                          ),
                          Text(
                            'Bi-directional calorie & burn sync',
                            style: ts(10, color: C.sub),
                          ),
                        ],
                      ),
                    ),
                    const Pill('Connected', bg: C.greenTint, fg: C.green),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const IconBox(
                      LucideIcons.focus,
                      color: C.blue,
                      tint: C.blueTint,
                      size: 34,
                      radius: 17,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Scanner HUD',
                            style: ts(12, w: FontWeight.w800),
                          ),
                          Text(
                            'Ultra-precise neural reticle',
                            style: ts(10, color: C.sub),
                          ),
                        ],
                      ),
                    ),
                    Text('Calibrated', style: ts(10, color: C.sub)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferences & Account',
                  style: ts(14, w: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                _row(
                  LucideIcons.utensils,
                  'Dietary Focus',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.goalTitle ?? 'High Protein',
                        style: ts(11, color: C.sub),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: C.sub,
                      ),
                    ],
                  ),
                ),
                _row(
                  LucideIcons.bell,
                  'Meal Reminders',
                  trailing: Switch(
                    value: _reminders,
                    activeColor: Colors.white,
                    activeTrackColor: C.green,
                    onChanged: (v) => setState(() => _reminders = v),
                  ),
                ),
                _row(
                  LucideIcons.shield,
                  'Privacy & HIPAA Data',
                  trailing: const Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: C.sub,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    LocalAuthService.instance.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                  child: _row(LucideIcons.logOut, 'Log Out', color: C.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String v, String unit, {bool green = false}) =>
      Expanded(
        child: Column(
          children: [
            Text(label, style: ts(10.5, color: C.sub)),
            const SizedBox(height: 2),
            Text(v, style: ts(17, w: FontWeight.w800)),
            Text(
              unit,
              style: ts(
                10,
                w: green ? FontWeight.w800 : FontWeight.w500,
                color: green ? C.green : C.sub,
              ),
            ),
          ],
        ),
      );

  Widget _legend(Color c, String a, String b) => Expanded(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a, style: ts(10, w: FontWeight.w800)),
            Text(b, style: ts(9, color: C.sub)),
          ],
        ),
      ],
    ),
  );

  Widget _row(
    IconData icon,
    String label, {
    Widget? trailing,
    Color color = C.text,
  }) => SizedBox(
    height: 46,
    child: Row(
      children: [
        Icon(icon, size: 19, color: color == C.red ? C.red : C.sub),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: ts(12.5, w: FontWeight.w600, color: color),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}
