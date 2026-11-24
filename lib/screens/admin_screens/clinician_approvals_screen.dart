import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/local_auth_service.dart';
import '../../theme.dart';

class ClinicianApprovalsScreen extends StatefulWidget {
  const ClinicianApprovalsScreen({super.key});

  @override
  State<ClinicianApprovalsScreen> createState() =>
      _ClinicianApprovalsScreenState();
}

class _ClinicianApprovalsScreenState extends State<ClinicianApprovalsScreen> {
  int _selectedTab = 0; // 0: Pending, 1: Approved, 2: Rejected

  String get _currentStatus => switch (_selectedTab) {
    1 => 'approved',
    2 => 'rejected',
    _ => 'pending',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: LocalAuthService.instance,
        builder: (context, _) {
          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              LocalAuthService.instance.getDoctorsByApproval('pending'),
              LocalAuthService.instance.getDoctorsByApproval('approved'),
              LocalAuthService.instance.getDoctorsByApproval(_currentStatus),
            ]),
            builder: (context, snapshot) {
              final pendingDocs =
                  (snapshot.data?[0] as List<AppUser>?) ?? const [];
              final approvedDocs =
                  (snapshot.data?[1] as List<AppUser>?) ?? const [];
              final visibleDocs =
                  (snapshot.data?[2] as List<AppUser>?) ?? const [];

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NUTRILENS ADMIN',
                              style: ts(
                                11,
                                w: FontWeight.w700,
                                color: C.brand,
                                ls: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Clinician Approvals',
                              style: ts(22, w: FontWeight.w700, color: C.text),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Review & verify doctor registrations',
                              style: ts(13, w: FontWeight.w400, color: C.sub),
                            ),
                          ],
                        ),
                      ),
                      _CircleIconButton(icon: Icons.search, onTap: () {}),
                      const SizedBox(width: 8),
                      _CircleIconButton(
                        icon: Icons.notifications_none_rounded,
                        hasDot: pendingDocs.isNotEmpty,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: C.lavender,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SegmentTab(
                            label: 'Pending',
                            count: pendingDocs.length,
                            isSelected: _selectedTab == 0,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                        ),
                        Expanded(
                          child: _SegmentTab(
                            label: 'Approved',
                            count: approvedDocs.length,
                            isSelected: _selectedTab == 1,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                        ),
                        Expanded(
                          child: _SegmentTab(
                            label: 'Rejected',
                            isSelected: _selectedTab == 2,
                            onTap: () => setState(() => _selectedTab = 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ApprovalStatCard(
                          title: 'Pending Requests',
                          value: '${pendingDocs.length}',
                          valueColor: C.orangeDark,
                          subtitle: 'in queue',
                          subtitleColor: C.orangeDark,
                          footerText: 'Requires license audit',
                          dotColor: C.orangeBar,
                          badgeIcon: Icons.access_time_rounded,
                          badgeColor: C.orangeBar,
                          badgeBg: C.amberTint,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ApprovalStatCard(
                          title: 'Active Doctors',
                          value: '${approvedDocs.length}',
                          valueColor: C.green,
                          subtitle: 'registered',
                          subtitleColor: C.green,
                          footerText: 'Syncing with clinics',
                          dotColor: C.green,
                          badgeIcon: Icons.check_circle_outline_rounded,
                          badgeColor: C.green,
                          badgeBg: C.greenTint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Queue (${visibleDocs.length})',
                        style: ts(15, w: FontWeight.w700),
                      ),
                      Text(
                        'Sorted by: Newest',
                        style: ts(12, w: FontWeight.w500, color: C.sub),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (visibleDocs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: C.cardBorder),
                      ),
                      child: Center(
                        child: Text(
                          'No clinicians in $_currentStatus status.',
                          style: ts(13, color: C.sub),
                        ),
                      ),
                    )
                  else
                    for (int i = 0; i < visibleDocs.length; i++) ...[
                      _ApprovalDoctorCard(
                        doctor: visibleDocs[i],
                        onApprove: () => LocalAuthService.instance
                            .approveDoctor(visibleDocs[i].id),
                        onReject: () => LocalAuthService.instance.rejectDoctor(
                          visibleDocs[i].id,
                        ),
                      ),
                      if (i != visibleDocs.length - 1)
                        const SizedBox(height: 14),
                    ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool hasDot;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    this.hasDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: C.card,
          shape: BoxShape.circle,
          border: Border.all(color: C.cardBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: C.text),
            if (hasDot)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: C.orangeBar,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? C.greenActive : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: ts(
                13,
                w: FontWeight.w600,
                color: isSelected ? Colors.white : C.subDark,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : C.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: ts(
                    11,
                    w: FontWeight.w700,
                    color: isSelected ? Colors.white : C.text,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ApprovalStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final String subtitle;
  final Color subtitleColor;
  final String footerText;
  final Color dotColor;
  final IconData badgeIcon;
  final Color badgeColor;
  final Color badgeBg;

  const _ApprovalStatCard({
    required this.title,
    required this.value,
    required this.valueColor,
    required this.subtitle,
    required this.subtitleColor,
    required this.footerText,
    required this.dotColor,
    required this.badgeIcon,
    required this.badgeColor,
    required this.badgeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts(12, w: FontWeight.w500, color: C.sub),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(badgeIcon, size: 15, color: badgeColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                maxLines: 1,
                style: ts(26, w: FontWeight.w700, color: valueColor),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts(12, w: FontWeight.w600, color: subtitleColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  footerText,
                  style: ts(11, w: FontWeight.w400, color: C.sub),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApprovalDoctorCard extends StatelessWidget {
  final AppUser doctor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalDoctorCard({
    required this.doctor,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final specialty = doctor.specialty ?? 'Clinical Nutrition';
    final clinic = doctor.org ?? 'Verified Clinic';
    final license = doctor.licenseNumber ?? 'LIC-PENDING';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.cardBorder),
      ),
      child: Column(
        children: [
          Text(doctor.fullName, style: ts(16, w: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: C.greenTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco_outlined, size: 13, color: C.greenDeep),
                const SizedBox(width: 5),
                Text(
                  specialty,
                  style: ts(11, w: FontWeight.w600, color: C.greenDeep),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_hospital_outlined, size: 14, color: C.sub),
              const SizedBox(width: 4),
              Text(
                clinic,
                style: ts(12, w: FontWeight.w400, color: C.sub),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: C.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: ts(12, color: C.sub),
                          children: [
                            const TextSpan(text: 'License: '),
                            TextSpan(
                              text: license,
                              style: ts(12, w: FontWeight.w700, color: C.text),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: C.hint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Status: ${doctor.approvalStatus}',
                            style: ts(11, w: FontWeight.w400, color: C.sub),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 15,
                    color: C.green,
                  ),
                  label: Text(
                    'View ID',
                    style: ts(12, w: FontWeight.w600, color: C.text),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: C.card,
                    side: const BorderSide(color: C.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (doctor.isPendingDoctor) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      'Approve',
                      style: ts(13, w: FontWeight.w600, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.greenActive,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: C.red,
                    ),
                    label: Text(
                      'Reject',
                      style: ts(13, w: FontWeight.w600, color: C.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: C.redSoft,
                      side: const BorderSide(color: C.redBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
