import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'custom_button.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    this.title = 'Terjadi Kesalahan',
    required this.message,
    required this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: WijiBumiColors.error.withOpacity(0.3),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: WijiBumiColors.error.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: WijiBumiColors.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 38,
                  color: WijiBumiColors.error,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: WijiBumiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: WijiBumiColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Coba Lagi',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                width: 160,
                height: 44,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
