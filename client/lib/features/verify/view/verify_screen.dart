import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({Key? key}) : super(key: key);

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  
  bool _isScanning = false;
  bool _hasPermission = false;
  bool _showSuccess = false;
  String? _scannedData;

  @override
  void initState() {
    super.initState();
    
    // Scanning line animation
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Pulse animation for corners
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Success animation
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _checkPermission();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    // Simulate permission check
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _hasPermission = true;
    });
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _showSuccess = false;
      _scannedData = null;
    });
    _scanLineController.repeat();
    
    // Simulate QR code detection after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_isScanning) {
        _onQRDetected("STUDENT_ID_12345");
      }
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scanLineController.stop();
    _scanLineController.reset();
  }

  void _onQRDetected(String data) {
    if (!_isScanning) return;
    
    HapticFeedback.mediumImpact();
    setState(() {
      _scannedData = data;
      _showSuccess = true;
      _isScanning = false;
    });
    
    _scanLineController.stop();
    _successController.forward(from: 0);
    
    // Show success dialog
    Future.delayed(const Duration(milliseconds: 800), () {
      _showResultDialog(data);
    });
  }

  void _showResultDialog(String data) {
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
            child: _buildResultDialog(data),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Title
                          _buildTitle(),

                          const SizedBox(height: 40),

                          // Scanner Frame
                          _buildScannerFrame(),

                          const SizedBox(height: 40),

                          // Instructions Card
                          _buildInstructionsCard(),

                          const SizedBox(height: 24),

                          // Scan Button
                          _buildScanButton(),

                          const SizedBox(height: 16),

                          // Manual Entry Option
                          _buildManualEntryButton(),
                        ],
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
                // Grid overlay
                if (_isScanning) _buildGridOverlay(),

                // Scanning line
                if (_isScanning) _buildScanningLine(),

                // Corner brackets
                _buildCornerBrackets(),

                // Center content
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _showSuccess
                        ? _buildSuccessIndicator()
                        : _buildCenterIcon(),
                  ),
                ),

                // Permission overlay
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
        // Top-left
        Positioned(
          top: 24,
          left: 24,
          child: _buildCorner(Alignment.topLeft),
        ),
        // Top-right
        Positioned(
          top: 24,
          right: 24,
          child: _buildCorner(Alignment.topRight),
        ),
        // Bottom-left
        Positioned(
          bottom: 24,
          left: 24,
          child: _buildCorner(Alignment.bottomLeft),
        ),
        // Bottom-right
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
                                    if (controller.text.isNotEmpty) {
                                      Navigator.pop(context);
                                      _onQRDetected(controller.text);
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

  Widget _buildResultDialog(String data) {
    return Center(
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
                  // Success animation
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success.withOpacity(0.3),
                          AppColors.success.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Verified Successfully!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
                            setState(() {
                              _showSuccess = false;
                              _scannedData = null;
                            });
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

// Custom painter for grid overlay
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const gridSize = 30.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
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

// Extension for gradient opacity
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