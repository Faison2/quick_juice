import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'root_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _enter(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RootShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: const BoxDecoration(
                      color: AppColors.brandGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Positioned(
                    left: 10,
                    top: 20,
                    child: Text('%', style: TextStyle(color: AppColors.brandGreen, fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  const Positioned(
                    right: 20,
                    bottom: 10,
                    child: Icon(Icons.circle_outlined, color: AppColors.brandGreen, size: 22),
                  ),
                  ClipOval(
                    child: Container(
                      width: 220,
                      height: 220,
                      color: AppColors.brandGreenTint,
                      child: const Icon(Icons.phone_iphone, color: AppColors.brandGreen, size: 90),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                'Smat Bills',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandGreenDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The convenient way to manage your utilities.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkMuted, fontSize: 14),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => _enter(context),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.brandGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _enter(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.brandGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(color: AppColors.brandGreen, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
