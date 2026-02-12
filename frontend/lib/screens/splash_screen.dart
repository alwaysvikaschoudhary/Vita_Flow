import 'package:flutter/material.dart';
import 'package:vita_flow/constants/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 120),

            Image.asset("assets/images/splash_logo.png", height: 400),

            const SizedBox(height: 16),

            const Text(
              "Connecting donors and seekers",
              style: TextStyle(fontSize: 13),
            ),
            const Text(
              "fast and simply",
              style: TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.only(bottom: 30, left: 30, right: 30),
              child: Text(
                "By continuing, you agree to our Terms of Service • Privacy Policy • Content Policy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
