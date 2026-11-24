import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/allergen_scan_service.dart';
import '../../theme.dart';
import 'allergy_alert_screen.dart';
import 'analysis_screen.dart';
import 'food_search.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cam;
  String? _error;
  XFile? _picked;
  bool _isEvaluating = false;

  final AllergenScanService _scanService = AllergenScanService();

  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (mounted) setState(() => _error = 'No camera found on this device');
        return;
      }
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final ctrl = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _cam = ctrl;
        _error = null;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(
        () => _error = e.code.contains('Denied')
            ? 'Camera permission denied. Enable it from system settings.'
            : (e.description ?? 'Camera error'),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _cam;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      setState(() => _cam = null);
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scan.dispose();
    _cam?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_isEvaluating) return;
    final picked = _picked;
    if (picked != null) {
      await _onImage(picked.path);
      return;
    }
    final c = _cam;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;
    HapticFeedback.mediumImpact();
    final file = await c.takePicture();
    if (!mounted) return;
    await _onImage(file.path);
  }

  Future<void> _onImage(String path) async {
    if (_isEvaluating) return;
    setState(() => _isEvaluating = true);

    try {
      final result = await _scanService.evaluateScan(imagePath: path);
      if (!mounted) return;

      final meal = result.meal;
      final effectiveImage = _picked != null ? _picked!.path : meal.imageAsset;

      if (result.hasAllergyConflict) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AllergyAlertScreen(
              imageAsset: meal.imageAsset,
              dishName: meal.dishName,
              matchPercent: meal.matchPercent,
              allergenTag: result.matchedAllergens.first,
              allergenNames: result.matchedAllergens.join(' & '),
              ingredients: result.criticalIngredients.isNotEmpty
                  ? result.criticalIngredients
                  : meal.ingredients,
              mealName: meal.mealName,
              mealType: meal.mealType,
              calories: meal.calories,
              protein: meal.proteinG,
              carbs: meal.carbsG,
              fat: meal.fatsG,
              accuracy: meal.accuracy,
              profileNote: result.profileNote,
              onRescan: () {
                Navigator.of(context).pop();
                setState(() => _picked = null);
              },
              onLogAnyway: () {
                Navigator.of(context).pop();
                _snack('${meal.mealName} logged with allergy warning');
              },
            ),
          ),
        );
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(
              imageAsset: effectiveImage,
              dishName: meal.dishName,
              matchPercent: meal.matchPercent.round(),
              calories: meal.calories,
              portionGrams: meal.portionGrams,
              proteinG: meal.proteinG,
              carbsG: meal.carbsG,
              fatsG: meal.fatsG,
              insight: meal.insight,
              onRetake: () {
                Navigator.of(context).pop();
                setState(() => _picked = null);
              },
              onLog: () {
                Navigator.of(context).pop();
                _snack('${meal.dishName} logged to diary');
              },
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) _snack('Could not evaluate food scan');
    } finally {
      if (mounted) setState(() => _isEvaluating = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _pickFromGallery() async {
    try {
      final f = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (f != null && mounted) setState(() => _picked = f);
    } catch (_) {
      if (mounted) _snack('Could not open the gallery');
    }
  }

  Future<void> _openSearch() async {
    final food = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FoodSearchSheet(),
    );
    if (food == null || !mounted || _isEvaluating) return;

    setState(() => _isEvaluating = true);
    try {
      final result = await _scanService.evaluateCustomFood(
        name: food.name,
        calories: food.kcal,
      );
      if (!mounted) return;

      final meal = result.meal;
      if (result.hasAllergyConflict) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AllergyAlertScreen(
              imageAsset: meal.imageAsset,
              dishName: meal.dishName,
              matchPercent: meal.matchPercent,
              allergenTag: result.matchedAllergens.first,
              allergenNames: result.matchedAllergens.join(' & '),
              ingredients: result.criticalIngredients.isNotEmpty
                  ? result.criticalIngredients
                  : meal.ingredients,
              mealName: meal.mealName,
              mealType: meal.mealType,
              calories: meal.calories,
              protein: meal.proteinG,
              carbs: meal.carbsG,
              fat: meal.fatsG,
              accuracy: meal.accuracy,
              profileNote: result.profileNote,
              onRescan: () => Navigator.of(context).pop(),
              onLogAnyway: () {
                Navigator.of(context).pop();
                _snack('${meal.mealName} logged with allergy warning');
              },
            ),
          ),
        );
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(
              imageAsset: meal.imageAsset,
              dishName: meal.dishName,
              matchPercent: meal.matchPercent.round(),
              calories: meal.calories,
              portionGrams: meal.portionGrams,
              proteinG: meal.proteinG,
              carbsG: meal.carbsG,
              fatsG: meal.fatsG,
              insight: meal.insight,
              onRetake: () => Navigator.of(context).pop(),
              onLog: () {
                Navigator.of(context).pop();
                _snack('${meal.dishName} logged to diary');
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isEvaluating = false);
    }
  }

  Widget _preview() {
    final picked = _picked;
    if (picked != null) {
      return Image.file(
        File(picked.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    final c = _cam;
    if (c == null || !c.value.isInitialized) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1B2D), Color(0xFF1C2B3C)],
          ),
        ),
      );
    }
    final s = c.value.previewSize!;
    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: s.height,
            height: s.width,
            child: CameraPreview(c),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final frameW = w * 0.78;
    final frameH = frameW * 0.85;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _preview(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: .55),
                    Colors.black.withValues(alpha: .15),
                    Colors.black.withValues(alpha: .25),
                    Colors.black.withValues(alpha: .72),
                  ],
                  stops: const [0, .3, .6, 1],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _circleBtn(
                          LucideIcons.x,
                          () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .45),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: C.neon,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                _isEvaluating
                                    ? 'CHECKING ALLERGENS...'
                                    : 'AI LENS ACTIVE',
                                style: ts(
                                  9.5,
                                  w: FontWeight.w800,
                                  color: Colors.white,
                                  ls: .8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: frameW,
                    height: frameH,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(frameW, frameH),
                          painter: _BracketPainter(),
                        ),
                        AnimatedBuilder(
                          animation: _scan,
                          builder: (_, __) => Positioned(
                            top:
                                16 +
                                (frameH - 32) *
                                    Curves.easeInOut.transform(_scan.value),
                            left: 16,
                            right: 16,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    C.neon.withValues(alpha: .9),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: C.neon.withValues(alpha: .5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: C.neon,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isEvaluating ? 'ANALYZING...' : 'DETECTING...',
                                style: ts(
                                  10,
                                  w: FontWeight.w800,
                                  color: C.neon,
                                  ls: .8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Point your camera at the food to analyze',
                          textAlign: TextAlign.center,
                          style: ts(
                            13.5,
                            w: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Auto-recognizing ingredients & macros',
                          textAlign: TextAlign.center,
                          style: ts(11, color: Colors.white70),
                        ),
                        if (_error != null && _picked == null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .65),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: .4),
                              ),
                            ),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: ts(10.5, color: Colors.amberAccent),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _picked == null
                        ? const SizedBox(height: 22)
                        : Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: GestureDetector(
                              onTap: () => setState(() => _picked = null),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: .55),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.x,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Back to camera',
                                      style: ts(
                                        10.5,
                                        w: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleBtn(
                          LucideIcons.image,
                          _pickFromGallery,
                          size: 46,
                        ),
                        GestureDetector(
                          onTap: _capture,
                          child: Container(
                            width: 78,
                            height: 78,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .35),
                                width: 2,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: C.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: C.green.withValues(alpha: .5),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: _isEvaluating
                                  ? const Padding(
                                      padding: EdgeInsets.all(22),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      LucideIcons.utensils,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                            ),
                          ),
                        ),
                        _circleBtn(LucideIcons.search, _openSearch, size: 46),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(
    IconData icon,
    VoidCallback onTap, {
    double size = 38,
    bool active = false,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .45),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Icon(icon, color: active ? C.neon : Colors.white, size: size * .5),
    ),
  );
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = C.neon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    const r = 16.0;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, len)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(len, 0)
      ..moveTo(w - len, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, len)
      ..moveTo(w, h - len)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(w - len, h)
      ..moveTo(len, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, h - len);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}
