import 'package:flutter/material.dart';

import '../../services/local_auth_service.dart';
import '../../theme.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    LocalAuthService.instance.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final admin = LocalAuthService.instance.currentUser;
    final fullName = admin?.fullName ?? 'System Admin';
    final email = admin?.email ?? 'admin@foodlens.com';
    final role = (admin?.role ?? 'admin').toUpperCase();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: C.greenTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: C.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Foodlens Admin',
                style: ts(16, w: FontWeight.w700, color: C.brand),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Admin Profile', style: ts(22, w: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Account details and session controls',
            style: ts(13, color: C.sub),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: C.cardBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: C.greenTint,
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 28,
                    color: C.green,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName, style: ts(16, w: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(email, style: ts(12, color: C.sub)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: C.greenBadge,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role,
                          style: ts(11, w: FontWeight.w700, color: C.greenDeep),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout_rounded, size: 18, color: C.red),
              label: Text(
                'Log Out',
                style: ts(14, w: FontWeight.w700, color: C.red),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: C.redSoft,
                side: const BorderSide(color: C.redBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
