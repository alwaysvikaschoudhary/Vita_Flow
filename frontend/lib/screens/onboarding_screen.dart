import 'package:flutter/material.dart';
import 'package:vita_flow/constants/app_colors.dart';
import 'package:vita_flow/constants/app_constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int pageIndex = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final onboardingData = [
    {
      "icon": Icons.favorite_border,
      "title": "Help Instantly",
      "desc": "Connect with those in need and make a difference in real-time",
    },
    {
      "icon": Icons.link,
      "title": "Connect Directly",
      "desc": "No middlemen. Direct connection between donors, doctors, and riders",
    },
    {
      "icon": Icons.shield_outlined,
      "Color": AppColors.secondary,
      "bgColor": const Color(0xFFE8F8E8),
      "title": "Save Lives",
      "desc": "Every donation counts. Be a hero in someone's story",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (i) => setState(() => pageIndex = i),
              itemCount: onboardingData.length,
              itemBuilder: (context, i) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        onboardingData[i]["icon"] as IconData,
                        color: AppColors.secondary,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      onboardingData[i]["title"] as String,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        onboardingData[i]["desc"] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey.withOpacity(0.7),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (i) => AnimatedContainer(
                duration: AppConstants.shortAnimation,
                margin: const EdgeInsets.all(4),
                height: 8,
                width: pageIndex == i ? 26 : 8,
                decoration: BoxDecoration(
                  color: pageIndex == i ? AppColors.primary : AppColors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Next / Get Started button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  ),
                ),
                onPressed: () {
                  if (pageIndex == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (c) => const Login()),
                    );
                  } else {
                    pageController.nextPage(
                      duration: AppConstants.mediumAnimation,
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  pageIndex == 2 ? "Get Started" : "Next",
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: AppConstants.fontSizeXLarge,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const Login()),
              );
            },
            child: const Text(
              "Skip",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
