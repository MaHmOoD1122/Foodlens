import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/local_auth_service.dart';
import '../../theme.dart';

class PlatformUsersScreen extends StatefulWidget {
  const PlatformUsersScreen({super.key});

  @override
  State<PlatformUsersScreen> createState() => _PlatformUsersScreenState();
}

class _PlatformUsersScreenState extends State<PlatformUsersScreen> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: LocalAuthService.instance,
        builder: (context, _) {
          return FutureBuilder<List<AppUser>>(
            future: LocalAuthService.instance.getPatients(),
            builder: (context, snapshot) {
              final allUsers = snapshot.data ?? const [];
              final linkedCount = allUsers
                  .where(
                    (u) =>
                        (u.doctorName != null && u.doctorName!.isNotEmpty) ||
                        (u.doctorCode != null && u.doctorCode!.isNotEmpty),
                  )
                  .length;
              final soloCount = allUsers.length - linkedCount;

              final query = _searchController.text.trim().toLowerCase();
              final filtered = allUsers.where((u) {
                final isLinked =
                    (u.doctorName != null && u.doctorName!.isNotEmpty) ||
                    (u.doctorCode != null && u.doctorCode!.isNotEmpty);

                final matchesChip = switch (_selectedFilter) {
                  1 => isLinked,
                  2 => !isLinked,
                  _ => true,
                };

                final matchesQuery =
                    query.isEmpty ||
                    u.fullName.toLowerCase().contains(query) ||
                    u.email.toLowerCase().contains(query) ||
                    u.id.toLowerCase().contains(query);

                return matchesChip && matchesQuery;
              }).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                color: C.orangeBar,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Platform Users', style: ts(22, w: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    'Account status and doctor-connection oversight',
                    style: ts(13, w: FontWeight.w400, color: C.sub),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: C.greenTint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: C.greenBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: C.greenDeep,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'HIPAA Compliant • Zero PHI View',
                            style: ts(
                              12,
                              w: FontWeight.w600,
                              color: C.greenDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
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
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: ts(14),
                            decoration: InputDecoration(
                              hintText: 'Search users...',
                              hintStyle: ts(14, color: C.hint),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Icon(
                            Icons.cancel_outlined,
                            size: 18,
                            color: C.hint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _UserFilterChip(
                          label: 'All',
                          count: '${allUsers.length}',
                          isSelected: _selectedFilter == 0,
                          onTap: () => setState(() => _selectedFilter = 0),
                        ),
                        const SizedBox(width: 8),
                        _UserFilterChip(
                          label: 'Linked to Doctor',
                          count: '$linkedCount',
                          isSelected: _selectedFilter == 1,
                          onTap: () => setState(() => _selectedFilter = 1),
                        ),
                        const SizedBox(width: 8),
                        _UserFilterChip(
                          label: 'Solo Account',
                          count: '$soloCount',
                          isSelected: _selectedFilter == 2,
                          onTap: () => setState(() => _selectedFilter = 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < filtered.length; i++) ...[
                    _PlatformUserCard(
                      user: filtered[i],
                      onToggleSuspend: () => LocalAuthService.instance
                          .toggleSuspendUser(filtered[i].id),
                    ),
                    if (i != filtered.length - 1) const SizedBox(height: 12),
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

class _UserFilterChip extends StatelessWidget {
  final String label;
  final String count;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : C.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: ts(
                  11,
                  w: FontWeight.w700,
                  color: isSelected ? Colors.white : C.sub,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformUserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onToggleSuspend;

  const _PlatformUserCard({required this.user, required this.onToggleSuspend});

  @override
  Widget build(BuildContext context) {
    final isSuspended = user.isSuspended;
    final linkedDoctor =
        (user.doctorName != null && user.doctorName!.isNotEmpty)
        ? user.doctorName
        : null;
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : (parts.first.isNotEmpty ? parts.first[0].toUpperCase() : 'U');

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
              CircleAvatar(
                radius: 17,
                backgroundColor: C.amberTint,
                child: Text(
                  initials,
                  style: ts(12, w: FontWeight.w700, color: C.orangeDark),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        style: ts(15, w: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.id,
                      style: ts(12, w: FontWeight.w500, color: C.hint),
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
                  color: isSuspended ? C.amberTint : C.greenTint,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSuspended ? C.amberBorder : C.greenBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: isSuspended ? C.orangeDark : C.green,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isSuspended ? 'Suspended' : 'Active',
                      style: ts(
                        11,
                        w: FontWeight.w600,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: C.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.cardBorder),
            ),
            child: linkedDoctor != null
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: C.greenTint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          size: 14,
                          color: C.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: ts(12, color: C.sub),
                            children: [
                              const TextSpan(text: 'Linked to: '),
                              TextSpan(
                                text: linkedDoctor,
                                style: ts(
                                  12,
                                  w: FontWeight.w700,
                                  color: C.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Icon(Icons.check_circle, size: 18, color: C.green),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: C.sub),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Independent / Solo Account',
                          style: ts(12, w: FontWeight.w500, color: C.subDark),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link_rounded,
                              size: 15,
                              color: C.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+ Link Doctor',
                              style: ts(12, w: FontWeight.w700, color: C.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            '${user.email}  •  ${user.goalTitle}',
            style: ts(11, w: FontWeight.w400, color: C.sub),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.manage_accounts_outlined,
                    size: 16,
                    color: C.subDark,
                  ),
                  label: Text(
                    'Manage Access',
                    style: ts(12, w: FontWeight.w600, color: C.text),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: C.card,
                    side: const BorderSide(color: C.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggleSuspend,
                  icon: Icon(
                    isSuspended
                        ? Icons.check_circle_outline
                        : Icons.block_rounded,
                    size: 16,
                    color: isSuspended ? C.green : C.red,
                  ),
                  label: Text(
                    isSuspended ? 'Reinstate User' : 'Suspend User',
                    style: ts(
                      12,
                      w: FontWeight.w600,
                      color: isSuspended ? C.green : C.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSuspended ? C.greenTint : C.redSoft,
                    side: BorderSide(
                      color: isSuspended ? C.greenBorder : C.redBorder,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
