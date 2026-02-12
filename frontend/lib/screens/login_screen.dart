import 'package:flutter/material.dart';
import 'package:vita_flow/screens/role_select.dart';
import 'package:vita_flow/screens/Doctor/navbar.dart';
import 'package:vita_flow/screens/Donar/donor_navbar.dart';
import 'package:vita_flow/screens/Rider/navbar.dart';
import 'package:vita_flow/services/api_service.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  bool isLoading = false;
  bool isOtpSent = false;

  Future<void> handleLogin() async {
    if (isOtpSent) {
      await verifyOtp();
    } else {
      await sendOtp();
    }
  }

  Future<void> sendOtp() async {
    setState(() => isLoading = true);
    try {
      final success = await ApiService.sendOtp(phoneController.text.trim());
      if (success) {
        setState(() {
          isOtpSent = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Sent! (Check console for mock OTP)")),
        );
      } else {
        throw Exception("Failed to send OTP");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> verifyOtp() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.verifyOtp(
        phoneController.text.trim(),
        otpController.text.trim(),
      );

      print("DEBUG: Verify OTP Response: $data");

      setState(() => isLoading = false);

      if (data != null) {
        print("DEBUG: Token check: ${data["token"]}");
        if (data["token"] != null) {
          // Existing User -> Dashboard
          print("DEBUG: Existing User Logic");
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Successful!")),
          );
          
          final role = data["user"]["role"];
          final user = data["user"];
          print("DEBUG: User Role: $role");
          
          if (role == "DONOR") {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DonorNavBar(currentUser: user)));
          } else if (role == "HOSPITAL" || role == "DOCTOR") {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DoctorNavBar(currentUser: user)));
          } else if (role == "RIDER") {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RiderNavBar(currentUser: user)));
          } else {
             print("DEBUG: Unknown User Role");
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unknown Role!")));
          }
        } else {
          // New User -> Role Select
          print("DEBUG: New User Logic -> Navigating to RoleSelectScreen");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RoleSelectScreen(phoneNumber: phoneController.text.trim()),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to VitaFlow",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isOtpSent ? "Enter OTP to verify" : "Login with Phone Number",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !isOtpSent,
                  validator: (v) => v!.isEmpty ? "Phone is required" : null,
                  decoration: _input("Phone Number"),
                ),

                if (isOtpSent) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "OTP is required" : null,
                    decoration: _input("Enter OTP"),
                  ),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              handleLogin();
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isOtpSent ? "Verify & Login" : "Get OTP"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
