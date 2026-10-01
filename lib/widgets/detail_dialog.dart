import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared shell for the "white card, close X, title, content, pill button(s)"
/// dialogs used across Confirm Details / Transaction History detail /
/// Choose Payment Profile / Choose Option.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  IconData? topIcon,
  required String title,
  required Widget child,
  String? primaryLabel,
  VoidCallback? onPrimary,
  Color primaryColor = AppColors.brandGreen,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  Color secondaryColor = AppColors.dangerRed,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black45,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            if (topIcon != null)
              Positioned(
                top: -34,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: AppColors.brandGreenTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(topIcon, color: AppColors.brandGreen, size: 32),
                ),
              ),
            Container(
              margin: EdgeInsets.only(top: topIcon != null ? 36 : 0),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: InkWell(
                          onTap: () => Navigator.of(ctx).pop(),
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.brandGreen),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.brandGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  child,
                  if (primaryLabel != null) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onPrimary,
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          primaryLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (secondaryLabel != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onSecondary,
                        style: FilledButton.styleFrom(
                          backgroundColor: secondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          secondaryLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.rowBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkMuted, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const OptionRow({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.brandGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final String brand;
  final String value;
  final String? subtitle;
  final VoidCallback onTap;

  const ProfileRow({
    super.key,
    required this.brand,
    required this.value,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.rowBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.brandGreen),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
                ],
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
