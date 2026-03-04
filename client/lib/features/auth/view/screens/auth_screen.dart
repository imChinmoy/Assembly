import 'dart:ui';
import 'dart:math' as math;
import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  bool _isLogin = true;

  late final AnimationController _bgCtrl;
  late final AnimationController _formCtrl;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut));

    _formCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _formCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    _formCtrl.reverse().then((_) {
      setState(() => _isLogin = !_isLogin);
      _formCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _AnimatedBackground(controller: _bgCtrl),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _formFade,
                  child: SlideTransition(
                    position: _formSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        _buildBrand(),
                        const SizedBox(height: 48),
                        _buildTabRow(),
                        const SizedBox(height: 36),
                        _isLogin
                            ? _LoginForm(onSwitch: _toggle)
                            : _SignupForm(onSwitch: _toggle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accentSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome\nBack.',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to continue scanning',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildTabRow() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: AppTheme.claymorphicDecorationInset(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _TabChip(
            label: 'Sign In',
            active: _isLogin,
            onTap: () { if (!_isLogin) _toggle(); },
          ),
          _TabChip(
            label: 'Sign Up',
            active: !_isLogin,
            onTap: () { if (_isLogin) _toggle(); },
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return SizedBox.expand(
          child: CustomPaint(
            painter: _BlobPainter(t),
          ),
        );
      },
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;
  _BlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final s1 = math.sin(t * math.pi * 2);
    final c1 = math.cos(t * math.pi * 2);
    final s2 = math.sin(t * math.pi * 2 + 1.2);
    final c2 = math.cos(t * math.pi * 2 + 2.4);

    _drawBlob(
      canvas,
      Offset(size.width * (0.75 + 0.12 * c1), size.height * (0.15 + 0.08 * s1)),
      size.width * 0.55,
      [
        AppColors.primary.withOpacity(0.22),
        Colors.transparent,
      ],
    );

    _drawBlob(
      canvas,
      Offset(size.width * (0.15 + 0.1 * s2), size.height * (0.65 + 0.1 * c2)),
      size.width * 0.5,
      [
        AppColors.accentSecondary.withOpacity(0.18),
        Colors.transparent,
      ],
    );

    _drawBlob(
      canvas,
      Offset(size.width * (0.5 + 0.08 * c2), size.height * (0.45 + 0.06 * s2)),
      size.width * 0.3,
      [
        AppColors.accent.withOpacity(0.10),
        Colors.transparent,
      ],
    );
  }

  void _drawBlob(Canvas canvas, Offset center, double radius, List<Color> colors) {
    final paint = Paint()
      ..shader = RadialGradient(colors: colors)
          .createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t;
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: active
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.textTertiary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatefulWidget {
  const _AuthField({
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.controller,
  });
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  bool _obscure = true;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _focused
                ? AppColors.primary.withOpacity(0.6)
                : AppColors.glassLight,
            width: _focused ? 1.5 : 1,
          ),
          color: AppColors.card,
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: AppColors.shadowDark,
                    blurRadius: 12,
                    offset: Offset(4, 4),
                  ),
                ],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(widget.icon, size: 20, color: _focused
                  ? AppColors.primary
                  : AppColors.textTertiary),
            ),
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}


class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.glassLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.glassLight)),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SocialButton(label: 'Google', icon: Icons.g_mobiledata_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _SocialButton(label: 'Apple', icon: Icons.apple_rounded)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: AppTheme.claymorphicDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.onSwitch});
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AuthField(
          hint: 'Email address',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        const _AuthField(
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(label: 'Sign In', onTap: () {}),
        const SizedBox(height: 28),
        const _OrDivider(),
        const SizedBox(height: 20),
        const _SocialRow(),
        const SizedBox(height: 32),
        Center(
          child: GestureDetector(
            onTap: onSwitch,
            child: RichText(
              text: const TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SignupForm extends StatelessWidget {
  const _SignupForm({required this.onSwitch});
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: _AuthField(
                hint: 'First name',
                icon: Icons.person_outline_rounded,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _AuthField(
                hint: 'Last name',
                icon: Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _AuthField(
          hint: 'Student ID',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 14),
        const _AuthField(
          hint: 'Email address',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        const _AuthField(
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 14),
        const _AuthField(
          hint: 'Confirm password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 28),
        _PrimaryButton(label: 'Create Account', onTap: () {}),
        const SizedBox(height: 20),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'By signing up, you agree to our ',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const _OrDivider(),
        const SizedBox(height: 20),
        const _SocialRow(),
        const SizedBox(height: 32),
        Center(
          child: GestureDetector(
            onTap: onSwitch,
            child: RichText(
              text: const TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}