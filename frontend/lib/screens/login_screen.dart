import 'package:flutter/material.dart';
import 'package:vita_flow/screens/role_select.dart';
import 'package:vita_flow/screens/Doctor/navbar.dart';
import 'package:vita_flow/screens/Donar/donor_navbar.dart';
import 'package:vita_flow/screens/Rider/navbar.dart';
import 'package:vita_flow/services/api_service.dart';

// ─────────────────────────────────────────────────────────
// Screen modes
// ─────────────────────────────────────────────────────────
enum _LoginMode { password, otp }

enum _ForgotStep { idle, otpSent, newPassword }

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  _LoginMode _mode = _LoginMode.password;
  _ForgotStep _forgotStep = _ForgotStep.idle;

  bool _isLoading = false;
  bool _isOtpSent = false; // for OTP login flow
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

  // ───────── OTP login ─────────
  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      _showSnack('Enter phone number first.', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final success = await ApiService.sendOtp(_phoneCtrl.text.trim());
      if (success) {
        setState(() => _isOtpSent = true);
        _showSnack('OTP sent!');
      } else {
        _showSnack('Failed to send OTP', error: true);
      }
    } catch (e) {
      _showSnack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.verifyOtp(
        _phoneCtrl.text.trim(),
        _otpCtrl.text.trim(),
      );
      if (!mounted) return;
      if (data != null) {
        if (data['token'] != null) {
          _showSnack('Login Successful!');
          _navigateByRole(data);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RoleSelectScreen(phoneNumber: _phoneCtrl.text.trim()),
            ),
          );
        }
      } else {
        _showSnack('Invalid OTP', error: true);
      }
    } catch (e) {
      _showSnack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ───────── Forgot password ─────────
  Future<void> _sendForgotOtp() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      _showSnack('Enter phone number first.', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService.sendOtp(_phoneCtrl.text.trim());
      setState(() => _forgotStep = _ForgotStep.otpSent);
      _showSnack('OTP sent to your number!');
    } catch (e) {
      _showSnack(e.toString(), error: true);
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
      await ApiService.resetPassword(
        _phoneCtrl.text.trim(),
        _otpCtrl.text.trim(),
        _newPassCtrl.text.trim(),
      );
      _showSnack('Password reset successfully! Please login.');
      setState(() {
        _forgotStep = _ForgotStep.idle;
        _mode = _LoginMode.password;
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo / Title
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.water_drop, color: Color(0xFFE0463A), size: 34),
                ),
                const SizedBox(height: 20),

                Text(
                  _forgotStep != _ForgotStep.idle
                      ? 'Reset Password'
                      : 'Welcome to VitaFlow',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _forgotStep != _ForgotStep.idle
                      ? 'Enter the OTP sent to your number'
                      : _mode == _LoginMode.password
                          ? 'Login with Phone & Password'
                          : _isOtpSent
                              ? 'Enter OTP to verify'
                              : 'Login with OTP',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 32),

                // ── Phone field (always shown) ──
                _buildField(
                  controller: _phoneCtrl,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  enabled: !_isOtpSent || _forgotStep != _ForgotStep.idle,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                ),

                // ─── FORGOT PASSWORD FLOW ───────────────────────
                if (_forgotStep == _ForgotStep.otpSent ||
                    _forgotStep == _ForgotStep.newPassword) ...[
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _otpCtrl,
                    label: 'Enter OTP',
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'OTP is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _newPassCtrl,
                    label: 'New Password',
                    icon: Icons.lock_reset_outlined,
                    obscure: _obscureNewPass,
                    toggleObscure: () =>
                        setState(() => _obscureNewPass = !_obscureNewPass),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Min 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),
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

                // ─── OTP LOGIN FLOW ─────────────────────────────
                else if (_mode == _LoginMode.otp) ...[
                  if (_isOtpSent) ...[
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _otpCtrl,
                      label: 'Enter OTP',
                      icon: Icons.lock_outline,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'OTP is required'
                          : null,
                    ),
                  ],
                ]

                // ─── PASSWORD LOGIN FLOW ─────────────────────────
                else ...[
                  const SizedBox(height: 16),
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
                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _forgotStep = _ForgotStep.otpSent;
                          _otpCtrl.clear();
                          _newPassCtrl.clear();
                          _confirmPassCtrl.clear();
                        });
                        _sendForgotOtp();
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFFE0463A)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Main Action Button ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
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

                const SizedBox(height: 18),

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
                ] else ...[
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() {
                        _mode = _mode == _LoginMode.password
                            ? _LoginMode.otp
                            : _LoginMode.password;
                        _isOtpSent = false;
                        _otpCtrl.clear();
                        _passwordCtrl.clear();
                      }),
                      child: Text(
                        _mode == _LoginMode.password
                            ? 'Login with OTP instead'
                            : 'Login with Password instead',
                        style: const TextStyle(color: Color(0xFFE0463A)),
                      ),
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
    if (_forgotStep != _ForgotStep.idle) return 'Reset Password';
    if (_mode == _LoginMode.password) return 'Login';
    return _isOtpSent ? 'Verify & Login' : 'Get OTP';
  }

  void _primaryAction() {
    if (_forgotStep != _ForgotStep.idle) {
      _resetPassword();
    } else if (_mode == _LoginMode.password) {
      _loginWithPassword();
    } else {
      _isOtpSent ? _verifyOtp() : _sendOtp();
    }
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
    _passwordCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }
}
