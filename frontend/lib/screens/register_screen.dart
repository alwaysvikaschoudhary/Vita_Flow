import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Doctor/navbar.dart';
import 'package:vita_flow/screens/Donar/donor_navbar.dart';
import 'package:vita_flow/screens/Rider/navbar.dart';
import 'package:vita_flow/screens/Location/location_picker_screen.dart';
import 'package:vita_flow/services/location_service.dart';
import 'package:intl/intl.dart';

class Register extends StatefulWidget {
  final String phoneNumber;
  final String role;
  const Register({Key? key, required this.phoneNumber, required this.role}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Role Specific Controllers
  final hospitalNameController = TextEditingController();
  final bikeNumberController = TextEditingController();
  final dobController = TextEditingController();

  String? selectedBloodGroup;
  String? selectedSpecialization;

  // Location
  double? _latitude;
  double? _longitude;
  String? _pickedAddress;
  bool _geocoding = false;

  bool isLoading = false;

  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> specializations = ['Cardiologist', 'Neurologist', 'General Physician', 'Orthopedic', 'Pediatrician', 'Other'];

  Future<void> save() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService.completeProfile({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": widget.role,
        "phoneNumber": widget.phoneNumber,
        "password": passwordController.text.trim(),
        
        // Role Params
        "bloodGroup": selectedBloodGroup,
        "dob": dobController.text.trim(),
        "hospitalName": hospitalNameController.text.trim(),
        "specialization": selectedSpecialization,
        "bikeNumber": bikeNumberController.text.trim(),
        // Location
        if (_latitude != null && _longitude != null)
          "ordinate": {"latitude": _latitude, "longitude": _longitude},
        if (_pickedAddress != null)
          "address": _pickedAddress,
      });

      setState(() => isLoading = false);

      if (data["token"] != null) {
        // TODO: Store token
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Completed!")),
        );

        final user = data["user"];
        
        // Navigate based on role
        if (widget.role == "DONOR") {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => DonorNavBar(currentUser: user)), (route) => false);
        } else if (widget.role == "HOSPITAL" || widget.role == "DOCTOR") {
             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => DoctorNavBar(currentUser: user)), (route) => false);
        } else if (widget.role == "RIDER") {
             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => RiderNavBar(currentUser: user)), (route) => false);
        } else {
             Navigator.pop(context);
        }

      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLat: _latitude,
          initialLng: _longitude,
        ),
      ),
    );
    if (result != null && result is Map) {
      final lat = (result['latitude'] as num).toDouble();
      final lng = (result['longitude'] as num).toDouble();
      final address = result['address'] as String?;
      
      setState(() {
        _latitude = lat;
        _longitude = lng;
        if (address != null && address.isNotEmpty) {
          _pickedAddress = address;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Profile")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "You are joining as ${widget.role == 'DOCTOR' ? 'Doctor / Hospital' : widget.role}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    initialValue: widget.phoneNumber,
                    readOnly: true,
                    decoration: _input("Phone Number"),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: nameController,
                    validator: (v) => v!.isEmpty ? "Name is required" : null,
                    decoration: _input("Full Name"),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Email is required";
                      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                      if (!emailRegex.hasMatch(v.trim())) return "Enter a valid email address";
                      return null;
                    },
                    decoration: _input("Email Address"),
                  ),
                  
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    validator: (v) => (v == null || v.length < 6) ? "Password must be at least 6 characters" : null,
                    decoration: _input("Password").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirm,
                    validator: (v) => v != passwordController.text ? "Passwords do not match" : null,
                    decoration: _input("Confirm Password").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------------------------
                  // ROLE SPECIFIC FIELDS
                  // ---------------------------

                  // DOB (Common for all)
                  TextFormField(
                    controller: dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (v) => v!.isEmpty ? "DOB is required" : null,
                    decoration: _input("Date of Birth").copyWith(
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // DONOR SPECIFIC
                  if (widget.role == "DONOR") ...[
                    DropdownButtonFormField<String>(
                      value: selectedBloodGroup,
                      items: bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => selectedBloodGroup = v),
                      validator: (v) => v == null ? "Select Blood Group" : null,
                      decoration: _input("Blood Group"),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // DOCTOR SPECIFIC
                  if (widget.role == "DOCTOR" || widget.role == "HOSPITAL") ...[
                    TextFormField(
                      controller: hospitalNameController,
                      validator: (v) => v!.isEmpty ? "Hospital Name is required" : null,
                      decoration: _input("Hospital Name"),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedSpecialization,
                      items: specializations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => selectedSpecialization = v),
                      validator: (v) => v == null ? "Select Specialization" : null,
                      decoration: _input("Specialization"),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // RIDER SPECIFIC
                  if (widget.role == "RIDER") ...[
                    TextFormField(
                      controller: bikeNumberController,
                      validator: (v) => v!.isEmpty ? "Bike/Vehicle Number is required" : null,
                      decoration: _input("Bike Number (e.g. RJ-14-AB-1234)"),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // LOCATION
                  const SizedBox(height: 4),
                  const Text(
                    "Location",
                    style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _latitude != null ? Colors.green : Colors.grey.shade400,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _latitude != null ? Colors.green.shade50 : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _latitude != null ? Icons.location_on : Icons.add_location_alt_outlined,
                            color: _latitude != null ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _geocoding
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    _latitude != null
                                        ? (_pickedAddress ?? "${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}")
                                        : "Tap to pick location on map",
                                    style: TextStyle(
                                      color: _latitude != null ? Colors.green.shade800 : Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                          if (_latitude != null && !_geocoding)
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        ],
                      ),
                    ),
                  ),
                
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (_latitude == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please pick your location on the map"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                save();
                              }
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Complete Profile"),
                    ),
                  ),
                ],
              ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
