import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_button.dart';

class GlassFeedback {
  /// Glass Snackbar
  static void showSnackbar({
    required String title,
    required String message,
    bool isError = false,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFC8DDD0),
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isError
          ? const Color(0xFFB71C1C).withOpacity(0.92)
          : const Color(0xFF1E2F21).withOpacity(0.94),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: isError ? const Color(0xFFFF8585) : const Color(0xFFA7F3D0),
      ),
      barBlur: 16,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.30),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Glass Dialog Konfirmasi dengan Dark Liquid Glass
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Konfirmasi',
    String cancelText = 'Batal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2F21).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFC8DDD0),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Tombol Batal Liquid Glass
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.0,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              cancelText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Tombol Konfirmasi (Mint Cerah)
                        CustomButton(
                          text: confirmText,
                          width: 120,
                          height: 40,
                          onPressed: () => Navigator.of(ctx).pop(true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Glass Loading Dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Memproses...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2F21).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA7F3D0)),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
