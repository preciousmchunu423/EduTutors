import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.radius = 28,
    this.backgroundColor = AppColors.blueSoft,
    this.iconColor = AppColors.blue,
    this.icon = Icons.person_outline_rounded,
    this.showCamera = false,
  });

  final double radius;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final bool showCamera;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            child: Icon(icon, color: iconColor, size: radius),
          ),
          if (showCamera)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 12, color: AppColors.navy),
              ),
            ),
        ],
      ),
    );
  }
}
