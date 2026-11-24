import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/local_auth_service.dart';
import '../../theme.dart';
import '../user_screens/allergies_page.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // حقول إضافية في حالة اختيار حساب Doctor
  final _specialtyCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();

  String _selectedRole = 'user'; // 'user' | 'doctor'
  bool isPasswordHidden = true;
  bool _isLoading = false;

  bool hasMinLength = false;
  bool hasNumberAndSymbol = false;
  int strengthLevel = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _specialtyCtrl.dispose();
    _orgCtrl.dispose();
    _licenseCtrl.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    final lengthValid = password.length >= 8;
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSymbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);

    int score = 0;
    if (password.isNotEmpty) {
      if (password.length >= 6) score++;
      if (lengthValid) score++;
      if (hasLetters && hasNumber) score++;
      if (hasNumber && hasSymbol) score++;
    }

    setState(() {
      hasMinLength = lengthValid;
      hasNumberAndSymbol = hasNumber && hasSymbol;
      strengthLevel = score;
    });
  }

  String get strengthText {
    if (strengthLevel == 0) return "";
    switch (strengthLevel) {
      case 1:
        return "Weak";
      case 2:
        return "Fair";
      case 3:
        return "Good";
      case 4:
        return "Strong";
      default:
        return "";
    }
  }

  Color get strengthColor {
    switch (strengthLevel) {
      case 1:
        return C.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.lightGreen;
      case 4:
        return C.brand;
      default:
        return C.track;
    }
  }

  Future<void> _handleCreateAccount() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your name, valid email, and a password (8+ chars).',
          ),
        ),
      );
      return;
    }

    if (_selectedRole == 'doctor') {
      if (_specialtyCtrl.text.trim().isEmpty ||
          _orgCtrl.text.trim().isEmpty ||
          _licenseCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter specialty, clinic/hospital, and license number.',
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final exists = await LocalAuthService.instance
          .isEmailTaken(email)
          .timeout(const Duration(seconds: 3));

      if (!mounted) return;

      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is already registered.')),
        );
        return;
      }

      if (_selectedRole == 'doctor') {
        final doctorUser = await LocalAuthService.instance.registerDoctor(
          fullName: name,
          email: email,
          password: pass,
          specialty: _specialtyCtrl.text,
          org: _orgCtrl.text,
          licenseNumber: _licenseCtrl.text,
        );
        if (!mounted) return;
        final destination = LocalAuthService.instance.resolveRoleDestination(
          doctorUser,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => destination),
          (_) => false,
        );
        return;
      }

      final onboardingData = OnboardingData()
        ..fullName = name
        ..email = email
        ..password = pass;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AllergiesPage(data: onboardingData)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: C.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: C.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: C.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: C.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: C.brand),
            ),
            prefixIcon: Icon(prefixIcon, size: 20, color: C.sub),
            suffixIcon: suffixIcon,
            hintText: hint,
            hintStyle: const TextStyle(color: C.hint, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: C.lavender,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = 'user'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedRole == 'user' ? C.brand : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  'Patient / User',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _selectedRole == 'user' ? Colors.white : C.subDark,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = 'doctor'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedRole == 'doctor'
                      ? C.brand
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  'Doctor / Clinician',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _selectedRole == 'doctor' ? Colors.white : C.subDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 340.0;

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: C.brand,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: C.greenLight, width: 4),
                  ),
                  child: const Icon(
                    Icons.center_focus_strong,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: C.greenBadge,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: C.brand, size: 14),
                      SizedBox(width: 6),
                      Text(
                        "Foodlens AI System",
                        style: TextStyle(
                          fontSize: 11,
                          color: C.brand,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: C.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Start your personalized nutrition journey today",
                  style: TextStyle(fontSize: 13, color: C.sub),
                ),
                const SizedBox(height: 20),
                Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: C.cardBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Account Type",
                        style: TextStyle(
                          fontSize: 12,
                          color: C.ink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildRoleSelector(),
                      const SizedBox(height: 14),
                      _buildInputField(
                        controller: _nameCtrl,
                        label: "Full Name",
                        hint: _selectedRole == 'doctor'
                            ? "Dr. Sarah Jenkins, MD"
                            : "Alex Johnson",
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildInputField(
                        controller: _emailCtrl,
                        label: "Email address",
                        hint: "alex@example.com",
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                      ),
                      if (_selectedRole == 'doctor') ...[
                        const SizedBox(height: 14),
                        _buildInputField(
                          controller: _specialtyCtrl,
                          label: "Specialty",
                          hint: "Clinical Nutrition & Dietetics",
                          prefixIcon: Icons.medical_services_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          controller: _orgCtrl,
                          label: "Clinic / Hospital",
                          hint: "Metropolitan Clinical Center",
                          prefixIcon: Icons.local_hospital_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          controller: _licenseCtrl,
                          label: "Medical License Number",
                          hint: "EGY-MED-2026-104",
                          prefixIcon: Icons.badge_outlined,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 12,
                              color: C.ink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            strengthText,
                            style: TextStyle(
                              fontSize: 11,
                              color: strengthColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: isPasswordHidden,
                        onChanged: _checkPasswordStrength,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: C.inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: C.inputBorder),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: C.sub,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordHidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: C.sub,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordHidden = !isPasswordHidden;
                              });
                            },
                          ),
                          hintText: "NutriLover2024!",
                          hintStyle: const TextStyle(
                            color: C.hint,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          4,
                          (index) => Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 3.5,
                              margin: EdgeInsets.only(
                                right: index == 3 ? 0 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: index < strengthLevel
                                    ? strengthColor
                                    : C.track,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            hasMinLength
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 14,
                            color: hasMinLength ? C.brand : C.sub,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "At least 8 characters",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: hasMinLength
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: hasMinLength ? C.ink : C.sub,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            hasNumberAndSymbol
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 14,
                            color: hasNumberAndSymbol ? C.brand : C.sub,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "1 number & symbol",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: hasNumberAndSymbol
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: hasNumberAndSymbol ? C.ink : C.sub,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: C.brand,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleCreateAccount,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _selectedRole == 'doctor'
                                          ? "Submit for Review"
                                          : "Create Account",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 13, color: C.subDark),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Log in",
                            style: TextStyle(
                              color: C.brand,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 16, color: C.brand),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
