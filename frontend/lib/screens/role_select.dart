import 'package:vita_flow/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:vita_flow/constants/app_colors.dart';
import 'package:vita_flow/constants/app_constants.dart';

class RoleSelectScreen extends StatefulWidget {
  final String phoneNumber;
  const RoleSelectScreen({super.key, required this.phoneNumber});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const SizedBox(height: 40),
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Choose your role",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select how you want to contribute to VitaFlow",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.grey.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Roles
              roleTile("Blood Donor", "DONOR", Icons.favorite),
              roleTile("Hospital / Doctor", "DOCTOR", Icons.local_hospital),
              roleTile("Rider / Volunteer", "RIDER", Icons.delivery_dining),

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => Register(
                            phoneNumber: widget.phoneNumber,
                            role: selectedRole!,
                          ),
                        ),
                      );
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

  Widget roleTile(String text, String value, IconData icon) {
    final isSelected = selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 80,
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
            CircleAvatar(
              backgroundColor: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.1),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.black,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedRole,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => selectedRole = v),
            ),
          ],
        ),
      ),
    );
  }
}
