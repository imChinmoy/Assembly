import 'dart:developer';

import 'package:client/core/theme/theme.dart';
import 'package:client/features/home/model/student_model.dart';
import 'package:client/features/home/repository/student_repo.dart';
import 'package:client/features/home/viewmodel/student_state_notifier.dart';
import 'package:client/features/verify/viewmodel/attendance_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:ui';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  final StudentRepo _studentRepo = StudentRepo();
  
  bool _isScanning = false;
  bool _hasPermission = false;
  bool _showSuccess = false;
  bool _attendanceUpdating = false;

  final TextEditingController _searchController = TextEditingController();
  StudentModel? _searchedStudent;
  bool _searchLoading = false;
  String? _searchError;
  List<StudentModel> _paginatedStudents = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalPlayers = 0;
  bool _listLoading = false;
  final TextEditingController _listSearchController = TextEditingController();
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    _checkPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPaginatedStudents());
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _scanLineController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _searchController.dispose();
    _listSearchController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
  final status = await Permission.camera.request();

  setState(() {
    _hasPermission = status.isGranted;
  });
}

  Future<void> _startScanning() async {
  final status = await Permission.camera.request();

  if (!status.isGranted) {
    setState(() => _hasPermission = false);
    return;
  }

  setState(() {
    _hasPermission = true;
    _isScanning = true;
    _showSuccess = false;
  });

  await _scannerController.start();
  _scanLineController.repeat();
}

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning || _attendanceUpdating) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final String? raw = barcodes.first.rawValue;
    if (raw == null || raw.trim().isEmpty) return;
    final String studentNo = raw.trim();
    log(studentNo);
    _processScannedStudentNo(studentNo);
  }

  Future<void> _processScannedStudentNo(String studentNo) async {
    if (_attendanceUpdating) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _attendanceUpdating = true;
      _showSuccess = true;
      _isScanning = false;
    });
    _scanLineController.stop();
    _successController.forward(from: 0);

    final notifier = ref.read(attendanceNotifierProvider.notifier);
    final success = await notifier.updateAttendance(studentNo, true);

    if (!mounted) return;
    setState(() => _attendanceUpdating = false);
    if (success) {
      if (_searchedStudent?.studentId == studentNo) _searchByStudentNo();
      _loadPaginatedStudents();
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showResultDialog(studentNo, success: success);
    });
  }

  void _stopScanning() {
  _scannerController.stop();

  setState(() {
    _isScanning = false;
  });

  _scanLineController.stop();
  _scanLineController.reset();
}

  void _showResultDialog(String data, {bool success = true}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation,
            child: _buildResultDialog(data, success: success),
          ),
        );
      },
    );
  }

  Future<void> _searchByStudentNo() async {
    final studentNo = _searchController.text.trim();
    if (studentNo.isEmpty) return;
    setState(() {
      _searchLoading = true;
      _searchError = null;
      _searchedStudent = null;
    });
    final student = await _studentRepo.getStudentByStudentNo(studentNo);
    if (!mounted) return;
    setState(() {
      _searchLoading = false;
      _searchedStudent = student;
      _searchError = student == null ? 'Student not found' : null;
    });
  }

  Future<void> _loadPaginatedStudents() async {
    setState(() => _listLoading = true);
    final result = await _studentRepo.getStudentsPaginated(
      page: _currentPage,
      limit: 20,
      search: _listSearchController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _listLoading = false;
      _paginatedStudents = List<StudentModel>.from(result['data'] ?? []);
      _totalPages = result['totalPages'] ?? 1;
      _totalPlayers = result['totalPlayers'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(studentNotifierProvider.notifier).refresh();
                    },
                    child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          _buildTitle(),

                          const SizedBox(height: 40),
                          _buildScannerFrame(),

                          const SizedBox(height: 40),

                          _buildInstructionsCard(),

                          const SizedBox(height: 24),

                          _buildScanButton(),

                          const SizedBox(height: 16),

                          _buildManualEntryButton(),

                          const SizedBox(height: 32),

                          _buildSearchSection(),

                          const SizedBox(height: 24),


                          _buildPaginatedListSection(),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.claymorphicDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Search by Student No",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Student number",
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _searchByStudentNo(),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _searchLoading ? null : _searchByStudentNo,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: AppTheme.claymorphicDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: _searchLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
            ],
          ),
          if (_searchError != null) ...[
            const SizedBox(height: 8),
            Text(
              _searchError!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
              ),
            ),
          ],
          if (_searchedStudent != null) ...[
            const SizedBox(height: 16),
            _buildStudentCard(_searchedStudent!),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.claymorphicDecorationInset(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.studentId,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (student.isPresent)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      "Present",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!student.isPresent)
            GestureDetector(
              onTap: () => _processScannedStudentNo(student.studentId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: AppTheme.claymorphicDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Text(
                  "Mark present",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaginatedListSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.claymorphicDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                "Browse students",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _listSearchController,
                  decoration: InputDecoration(
                    hintText: "Filter",
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) {
                    setState(() => _currentPage = 1);
                    _loadPaginatedStudents();
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() => _currentPage = 1);
                  _loadPaginatedStudents();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: AppTheme.claymorphicDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_listLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_paginatedStudents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  "No students found",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Column(
              children: _paginatedStudents
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildStudentCard(s),
                      ))
                  .toList(),
            ),
          if (_paginatedStudents.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentPage <= 1
                      ? null
                      : () {
                          setState(() => _currentPage--);
                          _loadPaginatedStudents();
                        },
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Page $_currentPage of $_totalPages ($_totalPlayers total)",
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _currentPage >= _totalPages
                      ? null
                      : () {
                          setState(() => _currentPage++);
                          _loadPaginatedStudents();
                        },
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.05 + _pulseController.value * 0.03),
                AppColors.background,
                AppColors.secondary.withOpacity(0.03 + _pulseController.value * 0.02),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.claymorphicDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: const Text(
              "QR Scanner",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.claymorphicDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          "Scan to Verify",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Position the QR code within the frame",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildScannerFrame() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 350),
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: _showSuccess
              ? AppTheme.claymorphicDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.2),
                      AppColors.success.withOpacity(0.1),
                    ],
                  ),
                )
              : AppTheme.claymorphicDecorationInset(
                  borderRadius: BorderRadius.circular(32),
                ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                if (_isScanning)
                  Positioned.fill(
                    child: MobileScanner(
                      onDetect: _onBarcodeDetected,
                      controller: _scannerController,
                    ),
                  ),
                if (_isScanning) _buildScanningLine(),

                _buildCornerBrackets(),

                if (!_isScanning)
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _showSuccess
                          ? _buildSuccessIndicator()
                          : _buildCenterIcon(),
                    ),
                  ),
                if (!_hasPermission) _buildPermissionOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return CustomPaint(
      painter: GridPainter(color: AppColors.primary.withOpacity(0.1)),
      size: Size.infinite,
    );
  }

  Widget _buildScanningLine() {
    return AnimatedBuilder(
      animation: _scanLineController,
      builder: (context, child) {
        return Positioned(
          top: _scanLineController.value * MediaQuery.of(context).size.width * 0.85,
          left: 20,
          right: 20,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary,
                  AppColors.primary,
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCornerBrackets() {
    return Stack(
      children: [
        Positioned(
          top: 24,
          left: 24,
          child: _buildCorner(Alignment.topLeft),
        ),
        Positioned(
          top: 24,
          right: 24,
          child: _buildCorner(Alignment.topRight),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          child: _buildCorner(Alignment.bottomLeft),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: _buildCorner(Alignment.bottomRight),
        ),
      ],
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final isActive = _isScanning || _showSuccess;
        final opacity = isActive 
            ? 0.6 + _pulseController.value * 0.4 
            : 0.4;
        
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _showSuccess
                  ? [AppColors.success, AppColors.success.withOpacity(0.7)]
                  : [
                      AppColors.primary.withOpacity(opacity),
                      AppColors.secondary.withOpacity(opacity * 0.8),
                    ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: alignment == Alignment.topLeft 
                  ? const Radius.circular(12) 
                  : Radius.zero,
              topRight: alignment == Alignment.topRight 
                  ? const Radius.circular(12) 
                  : Radius.zero,
              bottomLeft: alignment == Alignment.bottomLeft 
                  ? const Radius.circular(12) 
                  : Radius.zero,
              bottomRight: alignment == Alignment.bottomRight 
                  ? const Radius.circular(12) 
                  : Radius.zero,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterIcon() {
    return ShaderMask(
      key: const ValueKey('scanner'),
      shaderCallback: (bounds) =>
          AppTheme.primaryGradient.createShader(bounds),
      child: Icon(
        _isScanning 
            ? Icons.qr_code_scanner_rounded 
            : Icons.qr_code_2_rounded,
        size: 80,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSuccessIndicator() {
    return ScaleTransition(
      key: const ValueKey('success'),
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _successController,
          curve: Curves.elasticOut,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.success,
              AppColors.success.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPermissionOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              "Requesting camera permission...",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.claymorphicDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildInstructionItem(
            icon: Icons.center_focus_strong_rounded,
            title: "Align Properly",
            description: "Keep the QR code centered in the frame",
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.glassLight,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionItem(
            icon: Icons.light_mode_rounded,
            title: "Good Lighting",
            description: "Ensure adequate lighting for best results",
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.glassLight,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionItem(
            icon: Icons.speed_rounded,
            title: "Hold Steady",
            description: "Keep your device stable for quick scanning",
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _isScanning ? _stopScanning : _startScanning,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
        decoration: AppTheme.claymorphicDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _isScanning
              ? LinearGradient(
                  colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                )
              : AppTheme.primaryGradient,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isScanning ? Icons.stop_rounded : Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              _isScanning ? "Stop Scanning" : "Start Scanning",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntryButton() {
    return TextButton.icon(
      onPressed: _showManualEntryDialog,
      icon: const Icon(Icons.keyboard_rounded, size: 20),
      label: const Text("Enter ID Manually"),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: AppTheme.claymorphicDecoration(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.card.withOpacity(0.95),
                            AppColors.surface.withOpacity(0.9),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.glassLight,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppTheme.primaryGradient.createShader(bounds),
                            child: const Icon(
                              Icons.badge_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Enter Student ID",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: controller,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              hintText: "STUDENT_ID",
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.glassLight,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogButton(
                                  label: "Cancel",
                                  onTap: () => Navigator.pop(context),
                                  isPrimary: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDialogButton(
                                  label: "Verify",
                                  onTap: () {
                                    if (controller.text.trim().isNotEmpty) {
                                      Navigator.pop(context);
                                      _processScannedStudentNo(
                                          controller.text.trim());
                                    }
                                  },
                                  isPrimary: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildResultDialog(String data, {bool success = true}) {
    final isSuccess = success;
    final accentColor = isSuccess ? AppColors.success : AppColors.error;
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: AppTheme.claymorphicDecoration(
            borderRadius: BorderRadius.circular(32),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.card.withOpacity(0.95),
                      AppColors.surface.withOpacity(0.9),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.glassLight,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.3),
                            accentColor.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              accentColor,
                              accentColor.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.5),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: Icon(
                          isSuccess ? Icons.check_rounded : Icons.error_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isSuccess ? "Verified Successfully!" : "Verification Failed",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (!isSuccess)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Student not found or request failed.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: AppTheme.claymorphicDecorationInset(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.badge_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            data,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogButton(
                            label: "Scan Again",
                            onTap: () {
                              Navigator.pop(context);
                              setState(() => _showSuccess = false);
                            },
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDialogButton(
                            label: "Done",
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDialogButton({
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: isPrimary
            ? AppTheme.claymorphicDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: AppTheme.primaryGradient,
              )
            : AppTheme.claymorphicDecorationInset(
                borderRadius: BorderRadius.circular(14),
              ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const gridSize = 30.0;


    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

extension GradientOpacity on Gradient {
  Gradient withOpacity(double opacity) {
    if (this is LinearGradient) {
      final gradient = this as LinearGradient;
      return LinearGradient(
        colors: gradient.colors.map((c) => c.withOpacity(opacity)).toList(),
        begin: gradient.begin,
        end: gradient.end,
      );
    }
    return this;
  }
}