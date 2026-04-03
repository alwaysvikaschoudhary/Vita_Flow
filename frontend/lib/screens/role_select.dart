import 'package:vita_flow/screens/register_screen.dart';
import 'package:vita_flow/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/constants/app_colors.dart';
import 'package:vita_flow/constants/app_constants.dart';

class RoleSelectScreen extends StatefulWidget {
  final String? phoneNumber;
  const RoleSelectScreen({super.key, this.phoneNumber});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? selectedRole;
  final TextEditingController _phoneController = TextEditingController();
  bool _checkingPhone = false;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      _phoneController.text = widget.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               const SizedBox(height: 100),
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Choose your role",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "Select how you want to contribute to VitaFlow",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.grey.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              if (widget.phoneNumber == null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Enter your phone number",
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Roles
              roleTile("Blood Donor", "DONOR", Icons.favorite),
              roleTile("Hospital / Doctor", "DOCTOR", Icons.local_hospital),
              roleTile("Rider / Volunteer", "RIDER", Icons.delivery_dining),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90),
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
                    onPressed: (selectedRole == null || _checkingPhone) ? null : () async {
                      final phone = _phoneController.text.trim();
                      if (phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter your phone number")),
                        );
                        return;
                      }

                      setState(() => _checkingPhone = true);
                      try {
                        // Check if user already exists
                        final exists = await ApiService.checkUserExists(phone);
                        if (exists) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("A user with this phone number already exists. Please login instead."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          setState(() => _checkingPhone = false);
                          return;
                        }
                      } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Check failed: $e")),
                            );
                          }
                          setState(() => _checkingPhone = false);
                          return;
                      }

                      if (!mounted) return;
                      setState(() => _checkingPhone = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => Register(
                            phoneNumber: phone,
                            role: selectedRole!,
                          ),
                        ),
                      );
                    },
                    child: _checkingPhone 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Continue", style: TextStyle(color: AppColors.white, fontSize: 18)),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate back or to Login if it's the root
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const Login()),
                          );
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
        margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 5),
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
            CircleAvatar(
              backgroundColor: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.1),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            ),
            const SizedBox(width: 10),
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
