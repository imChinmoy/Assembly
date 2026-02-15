import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

class StatsHeader extends StatelessWidget {
  final List allStudents;
  final List filteredStudents;
  final VoidCallback onScanPressed;

  const StatsHeader({
    super.key,
    required this.allStudents,
    required this.filteredStudents,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    final presentCount = allStudents.where((s) => s.isPresent).length;
    final totalCount = allStudents.length;
    final percentage = totalCount > 0 
        ? ((presentCount / totalCount) * 100).toStringAsFixed(0)
        : "0";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.claymorphicDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people_rounded,
                  label: "Total",
                  value: totalCount.toString(),
                  gradient: AppTheme.primaryGradient,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.glassLight,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_rounded,
                  label: "Present",
                  value: presentCount.toString(),
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.glassLight,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.analytics_rounded,
                  label: "Rate",
                  value: "$percentage%",
                  gradient: AppTheme.accentGradient,
                ),
              ),
            ],
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
          _buildScannerButton(context),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: _applyGradientOpacity(gradient, 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildScannerButton(BuildContext context) {
    return GestureDetector(
      onTap: onScanPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: AppTheme.claymorphicDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.accentSecondary,
              AppColors.accentSecondary.withOpacity(0.8),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Scan QR Code",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Gradient _applyGradientOpacity(Gradient gradient, double opacity) {
    if (gradient is LinearGradient) {
      return LinearGradient(
        colors: gradient.colors.map((c) => c.withOpacity(opacity)).toList(),
        begin: gradient.begin,
        end: gradient.end,
      );
    }
    return gradient;
  }
}