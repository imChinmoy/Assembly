import 'dart:ui';
import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(context),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildInfoCard(),
                      const SizedBox(height: 16),
                      _buildMenuSection(
                        title: 'Account',
                        items: const [
                          _MenuItem(Icons.person_outline_rounded, 'Edit Profile', null),
                          _MenuItem(Icons.notifications_outlined, 'Notifications', 'On'),
                          _MenuItem(Icons.lock_outline_rounded, 'Privacy', null),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMenuSection(
                        title: 'App',
                        items: const [
                          _MenuItem(Icons.palette_outlined, 'Appearance', 'Dark'),
                          _MenuItem(Icons.language_rounded, 'Language', 'English'),
                          _MenuItem(Icons.help_outline_rounded, 'Help & Support', null),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSignOutButton(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: AppTheme.claymorphicDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.claymorphicDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_horiz_rounded,
                  size: 20, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeaderBackground(),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: -60,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentSecondary.withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatar(),
              const SizedBox(height: 16),
              const Text(
                'Chinmoy ',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'chin.cs@gmail.com',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildRoleBadge(),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.accentSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.card,
              child: const Text(
                'CS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success,
            border: Border.all(color: AppColors.background, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRoleBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primaryLight.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Student • CS Department',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('142', 'Scans', AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('98%', 'Success', AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('3rd', 'Year', AppColors.accentSecondary)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: AppTheme.claymorphicDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card,
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [accent, accent.withOpacity(0.7)],
            ).createShader(bounds),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.claymorphicDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Info',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.badge_rounded, 'Student ID', 'CS-2021-0042'),
          _buildInfoDivider(),
          _buildInfoRow(Icons.school_rounded, 'Faculty', 'Computer Science'),
          _buildInfoDivider(),
          _buildInfoRow(Icons.calendar_today_rounded, 'Enrolled', 'Sept 2021'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: AppTheme.claymorphicDecorationInset(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: AppColors.glassLight, height: 1),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: AppTheme.claymorphicDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildMenuItem(item),
                  if (i < items.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: AppColors.glassLight, height: 1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        splashColor: AppColors.primary.withOpacity(0.08),
        highlightColor: AppColors.primary.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: AppTheme.claymorphicDecorationInset(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (item.trailing != null) ...[
                Text(
                  item.trailing!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.error.withOpacity(0.35),
              width: 1.5,
            ),
            gradient: LinearGradient(
              colors: [
                AppColors.error.withOpacity(0.12),
                AppColors.error.withOpacity(0.06),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 10),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? trailing;

  const _MenuItem(this.icon, this.label, this.trailing);
}