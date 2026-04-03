import 'package:flutter/material.dart';
import 'package:vita_flow/screens/role_select.dart';
import 'package:vita_flow/screens/Doctor/navbar.dart';
import 'package:vita_flow/screens/Donar/donor_navbar.dart';
import 'package:vita_flow/screens/Rider/navbar.dart';
import 'package:vita_flow/screens/register_screen.dart';
import 'package:vita_flow/services/api_service.dart';

// ─────────────────────────────────────────────────────────
// Screen modes
// ─────────────────────────────────────────────────────────
enum _ForgotStep { idle, selectMethod, otpSent, newPassword }

enum _ForgotMethod { phone, email }

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // For forgot password via email
  final _passwordCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  _ForgotStep _forgotStep = _ForgotStep.idle;
  _ForgotMethod _forgotMethod = _ForgotMethod.phone;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureNewPass = true;

  // ───────── Navigation helper ─────────
  void _navigateByRole(Map<String, dynamic> data) {
    final role = data['user']['role'];
    final user = data['user'];
    if (role == 'DONOR') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => DonorNavBar(currentUser: user)));
    } else if (role == 'HOSPITAL' || role == 'DOCTOR') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => DoctorNavBar(currentUser: user)));
    } else if (role == 'RIDER') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => RiderNavBar(currentUser: user)));
    } else {
      _showSnack('Unknown role. Contact support.');
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade700 : null,
    ));
  }

  // ───────── Password login ─────────
  Future<void> _loginWithPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.loginWithPassword(
        _phoneCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (!mounted) return;
      if (data['token'] != null) {
        _showSnack('Login Successful!');
        _navigateByRole(data);
      } else {
        // New user — go to role selection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RoleSelectScreen(phoneNumber: _phoneCtrl.text.trim()),
          ),
        );
      }
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ───────── Forgot password ─────────
  Future<void> _sendForgotOtp() async {
    setState(() => _isLoading = true);
    try {
      bool success = false;
      if (_forgotMethod == _ForgotMethod.phone) {
        if (_phoneCtrl.text.trim().isEmpty) {
          _showSnack('Enter phone number first.', error: true);
          setState(() => _isLoading = false);
          return;
        }
        success = await ApiService.sendOtp(_phoneCtrl.text.trim());
      } else {
        if (_emailCtrl.text.trim().isEmpty) {
          _showSnack('Enter email address first.', error: true);
          setState(() => _isLoading = false);
          return;
        }
        success = await ApiService.sendEmailOtp(_emailCtrl.text.trim());
      }

      if (success) {
        setState(() => _forgotStep = _ForgotStep.otpSent);
        _showSnack('OTP sent successfully!');
      } else {
        _showSnack('Failed to send OTP', error: true);
      }
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      _showSnack('Passwords do not match', error: true);
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      _showSnack('Password must be at least 6 characters', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (_forgotMethod == _ForgotMethod.phone) {
        await ApiService.resetPassword(
          _phoneCtrl.text.trim(),
          _otpCtrl.text.trim(),
          _newPassCtrl.text.trim(),
        );
      } else {
        await ApiService.resetPasswordByEmail(
          _emailCtrl.text.trim(),
          _otpCtrl.text.trim(),
          _newPassCtrl.text.trim(),
        );
      }
      _showSnack('Password reset successfully! Please login.');
      setState(() {
        _forgotStep = _ForgotStep.idle;
        _otpCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
      });
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ───────── Build ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 50),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 120),

                Text(
                  _forgotStep != _ForgotStep.idle
                      ? 'Reset Password'
                      : 'Welcome to VitaFlow',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 2),

                Text(
                  _forgotStep == _ForgotStep.selectMethod
                      ? 'Choose how to receive OTP'
                      : _forgotStep == _ForgotStep.otpSent || _forgotStep == _ForgotStep.newPassword
                          ? 'Enter the OTP sent to your ${_forgotMethod == _ForgotMethod.phone ? 'phone' : 'email'}'
                          : 'Login with Phone & Password',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // ─── FORGOT PASSWORD METHOD SELECTION ───────────
                if (_forgotStep == _ForgotStep.selectMethod) ...[
                  _buildMethodCard(
                    title: 'Phone Number',
                    subtitle: 'Send OTP via SMS',
                    icon: Icons.phone_android,
                    selected: _forgotMethod == _ForgotMethod.phone,
                    onTap: () => setState(() => _forgotMethod = _ForgotMethod.phone),
                  ),
                  const SizedBox(height: 10),
                  _buildMethodCard(
                    title: 'Email Address',
                    subtitle: 'Send OTP via Email',
                    icon: Icons.email_outlined,
                    selected: _forgotMethod == _ForgotMethod.email,
                    onTap: () => setState(() => _forgotMethod = _ForgotMethod.email),
                  ),

                  const SizedBox(height: 10),

                  if (_forgotMethod == _ForgotMethod.phone)
                    _buildField(
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                    )
                  else
                    _buildField(
                      controller: _emailCtrl,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                    ),
                ]

                // ─── OTP / NEW PASSWORD FLOW ─────────────────────
                else if (_forgotStep == _ForgotStep.otpSent ||
                    _forgotStep == _ForgotStep.newPassword) ...[
                  _buildField(
                    controller: _otpCtrl,
                    label: 'Enter OTP',
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'OTP is required' : null,
                  ),
                  const SizedBox(height: 10),
                  _buildField(
                    controller: _newPassCtrl,
                    label: 'New Password',
                    icon: Icons.lock_reset_outlined,
                    obscure: _obscureNewPass,
                    toggleObscure: () =>
                        setState(() => _obscureNewPass = !_obscureNewPass),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'Min 8 characters'
                        : null,
                  ),
                  const SizedBox(height: 10),

                  _buildField(
                    controller: _confirmPassCtrl,
                    label: 'Confirm Password',
                    icon: Icons.lock_reset_outlined,
                    obscure: _obscureNewPass,
                    toggleObscure: () =>
                        setState(() => _obscureNewPass = !_obscureNewPass),
                    validator: (v) => (v != _newPassCtrl.text)
                        ? 'Passwords do not match'
                        : null,
                  ),
                ]

                // ─── LOGIN FLOW ─────────────────────────────────
                else ...[
                  _buildField(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 10),
                  _buildField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    toggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Password is required'
                        : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _forgotStep = _ForgotStep.selectMethod;
                          _otpCtrl.clear();
                          _newPassCtrl.clear();
                          _confirmPassCtrl.clear();
                        });
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFFE0463A)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // ── Main Action Button ──
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0463A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _primaryAction,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _primaryLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Mode switch / back links ──
                if (_forgotStep != _ForgotStep.idle) ...[
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() {
                        _forgotStep = _ForgotStep.idle;
                        _otpCtrl.clear();
                      }),
                      child: const Text('← Back to Login'),
                    ),
                  ),
                ],

                // ── Register link (only on main login screen) ──
                if (_forgotStep == _ForgotStep.idle) ...[
                  const SizedBox(height: 1),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RoleSelectScreen()),
                            );
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Color(0xFFE0463A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── primary button label & action ──
  String get _primaryLabel {
    if (_forgotStep == _ForgotStep.selectMethod) return 'Send OTP';
    if (_forgotStep == _ForgotStep.otpSent || _forgotStep == _ForgotStep.newPassword) return 'Reset Password';
    return 'Login';
  }

  void _primaryAction() {
    if (_forgotStep == _ForgotStep.selectMethod) {
      _sendForgotOtp();
    } else if (_forgotStep == _ForgotStep.otpSent || _forgotStep == _ForgotStep.newPassword) {
      _resetPassword();
    } else {
      _loginWithPassword();
    }
  }

  Widget _buildMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFE0463A) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected ? const Color(0xFFFFEEEE).withOpacity(0.3) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFFE0463A) : Colors.grey),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selected ? const Color(0xFFE0463A) : Colors.black87,
                  ),
                ),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFFE0463A)),
          ],
        ),
      ),
    );
  }

  // ── field builder ──
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    bool enabled = true,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: toggleObscure,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0463A), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
      ),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }
}
