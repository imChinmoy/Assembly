import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'dart:ui';

class CustomAppBar extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchPressed;

  const CustomAppBar({
    super.key,
    required this.onMenuPressed,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 180,
      collapsedHeight: 90,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface.withOpacity(0.8),
                  AppColors.card.withOpacity(0.6),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.glassLight,
                  width: 1,
                ),
              ),
            ),
            child: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 50),
              title: _buildAppBarTitle(),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildIconButton(
          icon: Icons.menu_rounded,
          onPressed: onMenuPressed,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildIconButton(
            icon: Icons.search_rounded,
            onPressed: onSearchPressed,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Assem",
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Hunters K-Pop',
                color: const Color.fromARGB(255, 194, 155, 218),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
            const TextSpan(
              text: "bly",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                fontFamily: 'Hunters K-Pop',
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: AppTheme.claymorphicDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(icon, size: 22),
          ),
        ),
      ),
    );
  }
}