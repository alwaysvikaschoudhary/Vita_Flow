import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';

class EditDonorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const EditDonorProfileScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<EditDonorProfileScreen> createState() => _EditDonorProfileScreenState();
}

class _EditDonorProfileScreenState extends State<EditDonorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController aboutController;
  late TextEditingController addressController;
  
  // Donor Specific
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController medicalHistoryController; // "None" if empty
  late TextEditingController genderController;
  late TextEditingController latController;
  late TextEditingController lngController;
  
  String? selectedBloodGroup;
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = widget.currentUser;
    nameController = TextEditingController(text: user['name'] ?? '');
    emailController = TextEditingController(text: user['email'] ?? '');
    aboutController = TextEditingController(text: user['about'] ?? '');
    addressController = TextEditingController(text: user['address'] ?? '');
    
    ageController = TextEditingController(text: user['age'] ?? '');
    weightController = TextEditingController(text: user['weight'] ?? '');
    heightController = TextEditingController(text: user['height'] ?? '');
    medicalHistoryController = TextEditingController(text: user['medicalHistory'] ?? '');
    genderController = TextEditingController(text: user['gender'] ?? '');
    
    double lat = 0.0;
    double lng = 0.0;
    if (user['ordinate'] != null) {
      lat = (user['ordinate']['latitude'] ?? 0.0).toDouble();
      lng = (user['ordinate']['longitude'] ?? 0.0).toDouble();
    }
    latController = TextEditingController(text: lat.toString());
    lngController = TextEditingController(text: lng.toString());

    selectedBloodGroup = user['bloodGroup'];
    if (selectedBloodGroup != null && !bloodGroups.contains(selectedBloodGroup)) {
      selectedBloodGroup = null; // Reset if invalid
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isLoading = true);

    try {
      final updatedData = {
        "phoneNumber": widget.currentUser['phoneNumber'], 
        "role": "DONOR", 
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "about": aboutController.text.trim(),
        "address": addressController.text.trim(),
        
        // Donor Fields
        "bloodGroup": selectedBloodGroup,
        "age": ageController.text.trim(),
        "weight": weightController.text.trim(),
        "height": heightController.text.trim(),
        "medicalHistory": medicalHistoryController.text.trim(),
        "gender": genderController.text.trim(),
        "ordinate": {
          "latitude": double.tryParse(latController.text) ?? 0.0,
          "longitude": double.tryParse(lngController.text) ?? 0.0,
        }
      };

      final response = await ApiService.completeProfile(updatedData);

      setState(() => isLoading = false);

      if (response != null && response['user'] != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!")),
        );
        Navigator.pop(context, response['user']); 
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField("Full Name", nameController),
                _buildTextField("Email", emailController),
                
                DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  items: bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => selectedBloodGroup = v),
                  decoration: InputDecoration(
                    labelText: "Blood Group",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                     Expanded(child: _buildTextField("Age", ageController)),
                     const SizedBox(width: 10),
                     Expanded(child: _buildTextField("Gender", genderController)),
                  ],
                ),
                
                Row(
                  children: [
                     Expanded(child: _buildTextField("Weight (kg)", weightController)),
                     const SizedBox(width: 10),
                     Expanded(child: _buildTextField("Height (cm)", heightController)),
                  ],
                ),
                
                Row(
                  children: [
                    Expanded(child: _buildTextField("Latitude", latController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField("Longitude", lngController)),
                  ],
                ),

                _buildTextField("Address", addressController, maxLines: 2),
                _buildTextField("Medical History", medicalHistoryController, maxLines: 2),
                _buildTextField("About", aboutController, maxLines: 3),
                
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: isLoading ? null : save,
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Save Changes", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
