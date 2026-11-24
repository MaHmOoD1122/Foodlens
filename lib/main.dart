import 'package:flutter/material.dart';

import 'screens/admin_screens/admin_shell.dart';
import 'screens/user_screens/allergies_page.dart';
import 'screens/auth/login.dart';
import 'screens/auth/sign_up.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      title: 'FoodLens AI System',
      home: const SignUp(),
      routes: {
        '/signup': (context) => const SignUp(),
        '/login': (context) => const LoginScreen(),
        '/allergies': (context) {
          final data = ModalRoute.of(context)!.settings.arguments as dynamic;
          return AllergiesPage(data: data);
        },
        '/admin': (context) => const AdminShell(),
        '/admin/approvals': (context) => const AdminShell(initialIndex: 0),
        '/admin/doctors': (context) => const AdminShell(initialIndex: 1),
        '/admin/users': (context) => const AdminShell(initialIndex: 2),
      },
    );
  }
}
