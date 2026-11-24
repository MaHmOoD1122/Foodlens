import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../screens/admin_screens/admin_shell.dart';
import '../screens/doctor_screens/doctor_shell.dart';
import '../screens/user_screens/main_tabs.dart';

class LocalAuthService extends ChangeNotifier {
  LocalAuthService._();
  static final LocalAuthService instance = LocalAuthService._();

  AppUser? currentUser;
  List<Map<String, dynamic>>? _usersCache;

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    if (_usersCache != null) return _usersCache!;
    try {
      final raw = await rootBundle.loadString('assets/data/mock_db.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _usersCache = (decoded['users'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('mock_db.json load fallback: $e');
      }
      _usersCache = [];
    }
    return _usersCache!;
  }

  Future<bool> isEmailTaken(String email) async {
    final users = await _loadUsers();
    final normalized = email.trim().toLowerCase();
    return users.any(
      (u) => ((u['email'] as String?) ?? '').toLowerCase() == normalized,
    );
  }

  Future<AppUser> registerUser(OnboardingData onboarding) async {
    final users = await _loadUsers();
    final newId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    final userMap = onboarding.toUserJson(newId);

    users.add(userMap);

    final created = AppUser.fromJson(userMap);
    currentUser = created;
    notifyListeners();
    return created;
  }

  Future<AppUser> registerDoctor({
    required String fullName,
    required String email,
    required String password,
    required String specialty,
    required String org,
    required String licenseNumber,
  }) async {
    final users = await _loadUsers();
    final now = DateTime.now().millisecondsSinceEpoch;
    final doctorMap = <String, dynamic>{
      'id': 'doc-$now',
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': 'doctor',
      'approvalStatus': 'pending',
      'accountStatus': 'active',
      'specialty': specialty.trim(),
      'org': org.trim(),
      'licenseNumber': licenseNumber.trim().toUpperCase(),
      'clinicCode': null,
    };

    users.add(doctorMap);
    final created = AppUser.fromJson(doctorMap);
    currentUser = created;
    notifyListeners();
    return created;
  }

  Future<AppUser?> login(String email, String password) async {
    final users = await _loadUsers();
    final normalizedEmail = email.trim().toLowerCase();

    for (final u in users) {
      final userEmail = ((u['email'] as String?) ?? '').toLowerCase();
      if (userEmail == normalizedEmail && u['password'] == password) {
        final loggedUser = AppUser.fromJson(u);
        currentUser = loggedUser;
        notifyListeners();
        return loggedUser;
      }
    }
    return null;
  }

  Future<List<AppUser>> getDoctorsByApproval(String status) async {
    final users = await _loadUsers();
    return users
        .map(AppUser.fromJson)
        .where((u) => u.isDoctor && u.approvalStatus == status)
        .toList();
  }

  Future<List<AppUser>> getPatients() async {
    final users = await _loadUsers();
    return users.map(AppUser.fromJson).where((u) => u.isUser).toList();
  }

  Future<void> approveDoctor(String doctorId) async {
    final users = await _loadUsers();
    for (final u in users) {
      if (u['id'] == doctorId) {
        u['approvalStatus'] = 'approved';
        u['accountStatus'] = 'active';
        u['clinicCode'] ??= 'DOC-${1000 + (doctorId.hashCode.abs() % 8999)}';
        break;
      }
    }
    notifyListeners();
  }

  Future<void> rejectDoctor(String doctorId) async {
    final users = await _loadUsers();
    for (final u in users) {
      if (u['id'] == doctorId) {
        u['approvalStatus'] = 'rejected';
        break;
      }
    }
    notifyListeners();
  }

  Future<void> toggleSuspendUser(String userId) async {
    final users = await _loadUsers();
    for (final u in users) {
      if (u['id'] == userId) {
        final current = (u['accountStatus'] as String?) ?? 'active';
        u['accountStatus'] = current == 'suspended' ? 'active' : 'suspended';
        break;
      }
    }
    notifyListeners();
  }

  Widget resolveRoleDestination(AppUser user) {
    if (user.isAdmin) {
      return const AdminShell();
    }
    if (user.isDoctor) {
      if (user.isPendingDoctor) {
        return const _PendingDoctorScreen();
      }
      return const Shell();
    }
    return const MainTabsScreen(initialIndex: 0);
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}

class _PendingDoctorScreen extends StatelessWidget {
  const _PendingDoctorScreen();

  @override
  Widget build(BuildContext context) {
    final doctor = LocalAuthService.instance.currentUser;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 56),
              const SizedBox(height: 16),
              const Text(
                'License Verification Pending',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hello ${doctor?.fullName ?? 'Doctor'}, your clinician account is waiting for admin review.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  LocalAuthService.instance.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
