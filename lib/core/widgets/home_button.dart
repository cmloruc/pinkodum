import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../app/router.dart';

/// Her ekrana sabit ana sayfa butonu — stack'te kaç ekran olursa olsun direkt döner.
class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.home_outlined, size: 22, color: AppColors.textSecondary),
      tooltip: 'Ana Sayfa',
      onPressed: () => context.go(AppRoutes.home),
    );
  }
}
