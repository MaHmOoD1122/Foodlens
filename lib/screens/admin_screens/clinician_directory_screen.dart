import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models.dart';
import '../../services/local_auth_service.dart';
import '../../theme.dart';

class ClinicianDirectoryScreen extends StatefulWidget {
  const ClinicianDirectoryScreen({super.key});

  @override
  State<ClinicianDirectoryScreen> createState() =>
      _ClinicianDirectoryScreenState();
}

class _ClinicianDirectoryScreenState extends State<ClinicianDirectoryScreen> {
  int _selectedFilter = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: LocalAuthService.instance,
        builder: (context, _) {
          return FutureBuilder<List<AppUser>>(
            future: LocalAuthService.instance.getDoctorsByApproval('approved'),
            builder: (context, snapshot) {
              final allApproved = snapshot.data ?? const [];
              final filtered = allApproved.where((doc) {
                final q = _query.trim().toLowerCase();
                final matchesQuery =
                    q.isEmpty ||
                    doc.fullName.toLowerCase().contains(q) ||
                    (doc.org ?? '').toLowerCase().contains(q) ||
                    (doc.clinicCode ?? '').toLowerCase().contains(q);

                final spec = (doc.specialty ?? '').toLowerCase();
                final matchesChip = switch (_selectedFilter) {
                  1 => spec.contains('nutrition') || spec.contains('diet'),
                  2 => spec.contains('sport') || spec.contains('metabol'),
                  _ => true,
                };
                return matchesQuery && matchesChip;
              }).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: C.green,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NutriLens Admin',
                            style: ts(16, w: FontWeight.w700, color: C.brand),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: C.text,
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 10,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: C.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clinician Directory',
                              style: ts(20, w: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Manage approved doctors and clinic licensing',
                              style: ts(12, w: FontWeight.w400, color: C.sub),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: C.neon,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user,
                              size: 13,
                              color: C.greenDeep,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'HIPAA Guarded',
                              style: ts(
                                11,
                                w: FontWeight.w700,
                                color: C.greenDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: C.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: C.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 20, color: C.hint),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => setState(() => _query = v),
                                  style: ts(13),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search doctor, clinic or DOC code...',
                                    hintStyle: ts(13, color: C.hint),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: C.border),
                        ),
                        child: const Icon(
                          Icons.filter_list_rounded,
                          color: C.subDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChipItem(
                          label: 'All',
                          badge: '${allApproved.length}',
                          isSelected: _selectedFilter == 0,
                          onTap: () => setState(() => _selectedFilter = 0),
                        ),
                        const SizedBox(width: 8),
                        _FilterChipItem(
                          label: 'Clinical Nutrition',
                          isSelected: _selectedFilter == 1,
                          onTap: () => setState(() => _selectedFilter = 1),
                        ),
                        const SizedBox(width: 8),
                        _FilterChipItem(
                          label: 'Sports & Dietetics',
                          isSelected: _selectedFilter == 2,
                          onTap: () => setState(() => _selectedFilter = 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _DirectoryStatCard(
                          title: 'Active Doctors',
                          value: '${allApproved.length}',
                          footer: 'Across registered clinics',
                          dotColor: C.green,
                          icon: Icons.medical_services_outlined,
                          iconColor: C.green,
                          iconBg: C.greenTint,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DirectoryStatCard(
                          title: 'Verified Clinics',
                          value: '${allApproved.length}',
                          footer: '94% pairing activity',
                          dotColor: C.blue,
                          icon: Icons.domain_outlined,
                          iconColor: C.blue,
                          iconBg: C.blueTint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < filtered.length; i++) ...[
                    _DirectoryDoctorCard(
                      doctor: filtered[i],
                      onToggleSuspend: () => LocalAuthService.instance
                          .toggleSuspendUser(filtered[i].id),
                    ),
                    if (i != filtered.length - 1) const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 20,
                      ),
                      label: Text(
                        '+ Register New Licensed Doctor',
                        style: ts(14, w: FontWeight.w600, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.greenActive,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? C.greenActive : C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? C.greenActive : C.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: ts(
                12,
                w: FontWeight.w600,
                color: isSelected ? Colors.white : C.subDark,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: ts(11, w: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DirectoryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String footer;
  final Color dotColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _DirectoryStatCard({
    required this.title,
    required this.value,
    required this.footer,
    required this.dotColor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: ts(12, w: FontWeight.w500, color: C.sub),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: ts(24, w: FontWeight.w700)),
          const SizedBox(height: 6),
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
                  footer,
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

class _DirectoryDoctorCard extends StatelessWidget {
  final AppUser doctor;
  final VoidCallback onToggleSuspend;

  const _DirectoryDoctorCard({
    required this.doctor,
    required this.onToggleSuspend,
  });

  @override
  Widget build(BuildContext context) {
    final isSuspended = doctor.isSuspended;
    final docCode = doctor.clinicCode ?? 'DOC-0000';
    final specialty = doctor.specialty ?? 'Clinical Nutrition';
    final clinic = doctor.org ?? 'Verified Clinic';
    final verificationText = doctor.licenseNumber?.isNotEmpty == true
        ? 'Verified ${doctor.licenseNumber}'
        : 'Verified License';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.fullName, style: ts(15, w: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSuspended ? C.lavender : C.greenBadge,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        specialty,
                        style: ts(
                          11,
                          w: FontWeight.w600,
                          color: isSuspended ? C.subDark : C.greenDeep,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSuspended ? C.amberTint : C.neon,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: isSuspended ? C.orangeDark : C.greenDeep,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isSuspended ? 'Suspended' : 'Active',
                      style: ts(
                        11,
                        w: FontWeight.w700,
                        color: isSuspended ? C.orangeDark : C.greenDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: C.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  size: 15,
                  color: C.sub,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    clinic,
                    style: ts(12, w: FontWeight.w500, color: C.subDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => Clipboard.setData(ClipboardData(text: docCode)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSuspended ? C.card : C.greenTint,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSuspended ? C.border : C.greenBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Code: ',
                          style: ts(11, w: FontWeight.w500, color: C.sub),
                        ),
                        Text(
                          docCode,
                          style: ts(
                            11,
                            w: FontWeight.w700,
                            color: isSuspended ? C.text : C.greenDeep,
                          ),
                        ),
                        if (!isSuspended) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.copy_rounded,
                            size: 12,
                            color: C.green,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: C.sub),
                  const SizedBox(width: 4),
                  Text(
                    'Linked Patients',
                    style: ts(11, w: FontWeight.w500, color: C.sub),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    isSuspended
                        ? Icons.warning_amber_rounded
                        : Icons.verified_user_outlined,
                    size: 14,
                    color: isSuspended ? C.orangeDark : C.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    verificationText,
                    style: ts(
                      11,
                      w: FontWeight.w600,
                      color: isSuspended ? C.orangeDark : C.subDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onToggleSuspend,
              style: OutlinedButton.styleFrom(
                backgroundColor: isSuspended ? C.amberSurface : C.card,
                side: BorderSide(color: isSuspended ? C.amberBorder : C.border),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSuspended) ...[
                    const Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 15,
                      color: C.amberDark,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    isSuspended
                        ? 'Reinstate / Review Audit'
                        : 'Manage Account / Suspend',
                    style: ts(
                      12,
                      w: FontWeight.w600,
                      color: isSuspended ? C.amberDark : C.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
