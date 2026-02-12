import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Doctor/navbar.dart';
import 'package:vita_flow/screens/Donar/donor_navbar.dart';
import 'package:vita_flow/screens/Rider/navbar.dart';
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
  final aboutController = TextEditingController();

  // Role Specific Controllers
  final hospitalNameController = TextEditingController();
  final bikeNumberController = TextEditingController();
  final dobController = TextEditingController();

  String? selectedBloodGroup;
  String? selectedSpecialization;

  bool isLoading = false;

  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> specializations = ['Cardiologist', 'Neurologist', 'General Physician', 'Orthopedic', 'Pediatrician', 'Other'];

  Future<void> save() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService.completeProfile(
        nameController.text.trim(),
        emailController.text.trim(),
        widget.role,
        widget.phoneNumber,
        aboutController.text.trim(),
        // Role Params
        bloodGroup: selectedBloodGroup,
        dob: dobController.text.trim(),
        hospitalName: hospitalNameController.text.trim(),
        specialization: selectedSpecialization,
        bikeNumber: bikeNumberController.text.trim(),
      );

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
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
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
                    decoration: _input("Email (Optional)"),
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

                  TextFormField(
                    controller: aboutController,
                    decoration: _input("About (Optional)"),
                    maxLines: 3,
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
