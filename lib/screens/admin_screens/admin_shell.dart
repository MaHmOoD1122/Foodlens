import 'package:flutter/material.dart';

import '../../theme.dart';
import 'admin_profile_screen.dart';
import 'clinician_approvals_screen.dart';
import 'clinician_directory_screen.dart';
import 'platform_users_screen.dart';

class AdminShell extends StatefulWidget {
  final int initialIndex;

  const AdminShell({super.key, this.initialIndex = 0});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    ClinicianApprovalsScreen(),
    ClinicianDirectoryScreen(),
    PlatformUsersScreen(),
    AdminProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _pages.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: C.card,
          border: Border(top: BorderSide(color: C.border, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.assignment_outlined,
                  label: 'Approvals',
                  badgeCount: 4,
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.medical_services_outlined,
                  label: 'Doctors',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Users',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.manage_accounts_outlined,
                  label: 'Profile',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badgeCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.badgeCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final contentColor = isSelected ? Colors.white : C.sub;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? C.greenActive : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconWithBadge(contentColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: ts(
                11,
                w: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(Color iconColor) {
    if (badgeCount == null) {
      return Icon(icon, color: iconColor, size: 22);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: iconColor, size: 22),
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: C.orangeBar,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$badgeCount',
              style: ts(9, w: FontWeight.w700, color: Colors.white, height: 1),
            ),
          ),
        ),
      ],
    );
  }
}
