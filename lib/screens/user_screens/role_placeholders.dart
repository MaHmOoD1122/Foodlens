import 'package:flutter/material.dart';

import '../../services/local_auth_service.dart';
import '../../theme.dart';
import '../auth/login.dart';

class DoctorDashboardPlaceholder extends StatelessWidget {
  const DoctorDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final user = LocalAuthService.instance.currentUser;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: C.red),
            onPressed: () {
              LocalAuthService.instance.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 64,
                color: C.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome, ${user?.fullName ?? "Doctor"}',
                style: ts(20, w: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Doctor Dashboard UI is coming next.',
                style: ts(13, color: C.sub),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDashboardPlaceholder extends StatelessWidget {
  const AdminDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final user = LocalAuthService.instance.currentUser;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: C.red),
            onPressed: () {
              LocalAuthService.instance.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 64,
                color: C.brand,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome, ${user?.fullName ?? "Admin"}',
                style: ts(20, w: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Admin Control Panel UI is coming next.',
                style: ts(13, color: C.sub),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
