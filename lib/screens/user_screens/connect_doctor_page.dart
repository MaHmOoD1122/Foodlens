import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/local_auth_service.dart';
import '../../theme.dart';
import 'done_page.dart';

class DoctorPage extends StatefulWidget {
  final OnboardingData data;
  const DoctorPage({super.key, required this.data});
  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final controller = TextEditingController();
  Doctor? found;
  bool loading = false;
  bool notFound = false;

  OnboardingData get d => widget.data;

  Future<void> apply() async {
    setState(() {
      loading = true;
      notFound = false;
      found = null;
    });
    final doctor = await findClinic(controller.text);
    if (!mounted) return;
    setState(() {
      loading = false;
      found = doctor;
      notFound = doctor == null;
    });
  }

  Future<void> finish({bool solo = false}) async {
    d.doctor = solo ? null : found;
    setState(() => loading = true);
    await LocalAuthService.instance.registerUser(d);
    if (!mounted) return;
    setState(() => loading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => DonePage(data: d)),
      (_) => false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _card({
    required Widget child,
    bool selected = false,
    VoidCallback? onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? C.greenTint : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? C.green : C.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Row(
                      children: List.generate(
                        4,
                        (i) => Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: C.green,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('4 / 4', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Have a Doctor or Dietitian?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter your specialist's clinic code to sync your meal scans and get customized targets.",
                      style: TextStyle(color: C.sub),
                    ),
                    const SizedBox(height: 16),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Clinic Connection Code',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    hintText: 'DOC-8849',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: C.green,
                                ),
                                onPressed: loading ? null : apply,
                                child: loading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Apply'),
                              ),
                            ],
                          ),
                          if (found != null)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: C.green,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Verified Clinician Match found in Registry',
                                    style: TextStyle(
                                      color: C.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (notFound)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Code not found, please check and try again.',
                                style: TextStyle(color: C.red, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (found != null) ...[
                      const SizedBox(height: 12),
                      _card(
                        selected: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 26,
                                  child: Icon(Icons.person),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        found!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        found!.org,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: C.sub,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text(
                                          found!.title,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            const Text(
                              'Active sync protections enabled:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            for (final t in const [
                              'Automatic meal scan sharing & AI confidence check',
                              'Live allergen safety locks applied to your camera',
                              'Real-time macro adjustments & doctor directives',
                            ])
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: C.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        t,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Center(
                      child: Text('OR', style: TextStyle(color: C.sub)),
                    ),
                    const SizedBox(height: 12),
                    _card(
                      onTap: () {},
                      child: const Row(
                        children: [
                          Icon(Icons.qr_code_scanner),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Scan Doctor's QR Badge",
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Use camera for instant clinic badge pairing',
                                  style: TextStyle(fontSize: 12, color: C.sub),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: C.green),
                  onPressed: found == null ? null : () => finish(),
                  child: const Text(
                    'Connect & Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => finish(solo: true),
              child: const Text("I'm doing this solo (Skip for now)"),
            ),
          ],
        ),
      ),
    );
  }
}
