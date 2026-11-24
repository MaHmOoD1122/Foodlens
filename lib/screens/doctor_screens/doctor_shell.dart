import 'package:flutter/material.dart';

import '../../state.dart';
import '../../theme.dart';
import 'alerts_page.dart';
import 'doctor_profile_page.dart';
import 'patients_page.dart';
import 'protocols_page.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (_, __) {
      final n = app.openAlerts.length;
      return Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: tab,
            children: const [
              PatientsPage(),
              ProtocolsPage(),
              AlertsPage(),
              DoctorProfilePage(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          backgroundColor: Colors.white,
          indicatorColor: C.greenLight,
          destinations: [
            NavigationDestination(
              icon: Badge(
                label: Text('${app.patients.length}'),
                child: const Icon(Icons.groups_outlined),
              ),
              label: 'Patients',
            ),
            const NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              label: 'Protocols',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: n > 0,
                label: Text('$n'),
                child: const Icon(Icons.notifications_none),
              ),
              label: 'Alerts',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      );
    },
  );
}
