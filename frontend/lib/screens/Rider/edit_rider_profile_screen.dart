import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';

class EditRiderProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const EditRiderProfileScreen({super.key, required this.currentUser});

  @override
  State<EditRiderProfileScreen> createState() => _EditRiderProfileScreenState();
}

class _EditRiderProfileScreenState extends State<EditRiderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController bikeNumberController;
  late TextEditingController licenseController;
  late TextEditingController vehicleTypeController;
  late TextEditingController addressController;
  late TextEditingController aboutController;
  
  String? selectedGender;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentUser['name']);
    emailController = TextEditingController(text: widget.currentUser['email']);
    bikeNumberController = TextEditingController(text: widget.currentUser['bikeNumber']);
    licenseController = TextEditingController(text: widget.currentUser['license']);
    vehicleTypeController = TextEditingController(text: widget.currentUser['vehicleType']);
    addressController = TextEditingController(text: widget.currentUser['address']);
    aboutController = TextEditingController(text: widget.currentUser['about']);
    selectedGender = widget.currentUser['gender'];
  }

  Future<void> save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      
      Map<String, dynamic> updateData = {
        "phoneNumber": widget.currentUser['phoneNumber'],
        "role": "RIDER",
        "name": nameController.text,
        "email": emailController.text,
        "bikeNumber": bikeNumberController.text,
        "license": licenseController.text,
        "vehicleType": vehicleTypeController.text,
        "address": addressController.text,
        "about": aboutController.text,
        "gender": selectedGender,
      };

      try {
        final res = await ApiService.completeProfile(updateData);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully!")),
          );
          Navigator.pop(context, res['user']);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Full Name", nameController),
              _buildTextField("Email", emailController),
              _buildTextField("Bike Number", bikeNumberController),
              _buildTextField("License Details", licenseController),
              _buildTextField("Vehicle Type", vehicleTypeController),
              
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: ["Male", "Female", "Other"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedGender = val),
                decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              _buildTextField("Address", addressController),
              _buildTextField("About", aboutController, maxLines: 3),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isLoading ? null : save,
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Save Changes", style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
