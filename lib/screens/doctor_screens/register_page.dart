import 'package:flutter/material.dart';

import '../../common.dart';
import '../../state.dart';
import '../../theme.dart';
import 'doctor_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController(),
      clinic = TextEditingController(),
      lic = TextEditingController();
  String? spec, fileName;
  final specs = [
    'Clinical Nutrition & Dietetics',
    'Endocrinology',
    'Sports Nutrition',
    'Pediatric Nutrition',
  ];
  bool submitted = false;
  static final licRe = RegExp(r'^[A-Z]{3}-[A-Z]{3}-\d{4}-\d{4}$');

  String? get eName =>
      submitted && name.text.trim().length < 3 ? 'Enter your full name' : null;
  String? get eSpec => submitted && spec == null ? 'Select a specialty' : null;
  String? get eClinic =>
      submitted && clinic.text.trim().isEmpty ? 'Enter your clinic' : null;
  String? get eLic => submitted && !licRe.hasMatch(lic.text.trim())
      ? 'Format: EGY-MED-2026-9842'
      : null;
  String? get eFile =>
      submitted && fileName == null ? 'Attach your license' : null;

  void submit() {
    setState(() => submitted = true);
    if ([eName, eSpec, eClinic, eLic, eFile].any((e) => e != null)) return;
    app.register(name.text.trim());
    snack(context, 'Application submitted ✓');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Shell()),
    );
  }

  @override
  void dispose() {
    name.dispose();
    clinic.dispose();
    lic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'NutriLens Portal',
        style: ts(14, w: FontWeight.w700, color: C.green),
      ),
      centerTitle: true,
      leading: TextButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Shell()),
        ),
        child: const Text('‹ Skip'),
      ),
      leadingWidth: 70,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Tag(
            'Verification Stage 1 of 2',
            bg: C.greenLight,
            fg: C.green,
          ),
        ),
        const SizedBox(height: 6),
        Text('Doctor Registration', style: ts(22, w: FontWeight.w800)),
        Text(
          'Submit your clinical credentials for verification and licensing.',
          style: ts(12, color: C.sub),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clinician Credentials', style: ts(15, w: FontWeight.w700)),
              _l('Full Medical Name *'),
              TextField(
                controller: name,
                decoration: fieldDeco('Dr. Elena Vance', error: eName),
                onChanged: (_) => setState(() {}),
              ),
              _l('Medical Specialty *'),
              DropdownButtonFormField<String>(
                value: spec,
                isExpanded: true,
                decoration: fieldDeco('Select', error: eSpec),
                items: [
                  for (final s in specs)
                    DropdownMenuItem(
                      value: s,
                      child: Text(s, style: ts(13)),
                    ),
                ],
                onChanged: (v) => setState(() => spec = v),
              ),
              _l('Clinic / Hospital Affiliation *'),
              TextField(
                controller: clinic,
                decoration: fieldDeco(
                  'Metropolitan Nutrition Center',
                  error: eClinic,
                ),
                onChanged: (_) => setState(() {}),
              ),
              _l(
                'Medical Syndicate / License No. *${licRe.hasMatch(lic.text.trim()) ? '   ✓ Validated' : ''}',
              ),
              TextField(
                controller: lic,
                decoration: fieldDeco('EGY-MED-2026-9842', error: eLic),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medical License Attachment',
                style: ts(15, w: FontWeight.w700),
              ),
              Text(
                'Upload Syndicate Card or Official Medical Practice License (PDF or Photo).',
                style: ts(12, color: C.sub),
              ),
              const SizedBox(height: 8),
              if (fileName != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: C.greenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: C.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName!,
                          style: ts(12, w: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => fileName = null),
                        icon: const Icon(Icons.delete, color: C.red, size: 20),
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton.icon(
                  // swap for file_picker package in production
                  onPressed: () =>
                      setState(() => fileName = 'License_Certificate.pdf'),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload file'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              if (eFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(eFile!, style: ts(11, color: C.red)),
                ),
              const SizedBox(height: 6),
              Text(
                'PDF, PNG, JPG up to 15MB. Encrypted via 256-bit TLS.',
                style: ts(11, color: C.sub),
              ),
            ],
          ),
        ),
        AppCard(
          bg: C.indigoTint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NutriLens Clinical Board Review',
                style: ts(12, w: FontWeight.w700),
              ),
              Text(
                'Your credentials will be reviewed within 24 hours before your clinic prescription code is activated.',
                style: ts(12, color: C.sub),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          style: greenBtn(),
          child: const Text('Submit Application for Review →'),
        ),
      ],
    ),
  );

  Widget _l(String t) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 5),
    child: Text(t, style: ts(12, w: FontWeight.w600)),
  );
}
