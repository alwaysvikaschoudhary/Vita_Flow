import 'package:vita_flow/screens/Doctor/navbar.dart';
import 'package:vita_flow/screens/Donar/donor_navbar.dart';
import 'package:vita_flow/screens/Rider/navbar.dart';
import 'package:flutter/material.dart';
import 'package:vita_flow/constants/app_colors.dart';
import 'package:vita_flow/constants/app_constants.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),

              CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: const Icon(Icons.person, color: AppColors.primary, size: 65),
              ),

              const SizedBox(height: 30),

              const Text(
                "Welcome to VitaFlow",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              Text(
                "Select your role",
                style: TextStyle(fontSize: 16, color: AppColors.grey.withOpacity(0.7)),
              ),

              const SizedBox(height: 30),

              roleTile("Donor"),
              roleTile("Doctor"),
              roleTile("Rider"),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
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
                    onPressed: selectedRole == null ? null : () {
                      if (selectedRole == "Donor") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const DonorNavBar()),
                        );
                      } else if (selectedRole == "Doctor") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const DoctorNavBar()),
                        );
                      } else if (selectedRole == "Rider") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const RiderNavBar()),
                        );
                      }
                    },
                    child: const Text("Continue", style: TextStyle(color: AppColors.white, fontSize: 18)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget roleTile(String text) {
    final isSelected = selectedRole == text;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = text),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 70,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1) 
              : AppColors.white,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: text,
              groupValue: selectedRole,
              fillColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  return isSelected ? AppColors.primary : AppColors.grey;
                },
              ),
              onChanged: (v) => setState(() => selectedRole = v),
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 17,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
