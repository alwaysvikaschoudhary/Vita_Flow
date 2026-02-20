import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Location/location_picker_screen.dart';

class EditDoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const EditDoctorProfileScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<EditDoctorProfileScreen> createState() => _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController hospitalNameController;
  late TextEditingController specializationController;
  late TextEditingController aboutController;
  late TextEditingController addressController;
  late TextEditingController degreeController;
  late TextEditingController experienceController;
  late TextEditingController genderController;
  late TextEditingController latController;
  late TextEditingController lngController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = widget.currentUser;
    nameController = TextEditingController(text: user['name'] ?? '');
    emailController = TextEditingController(text: user['email'] ?? '');
    hospitalNameController = TextEditingController(text: user['hospitalName'] ?? '');
    specializationController = TextEditingController(text: user['specialization'] ?? '');
    aboutController = TextEditingController(text: user['about'] ?? '');
    addressController = TextEditingController(text: user['address'] ?? '');
    degreeController = TextEditingController(text: user['degree'] ?? '');
    experienceController = TextEditingController(text: user['experience'] ?? '');
    genderController = TextEditingController(text: user['gender'] ?? '');
    
    double lat = 0.0;
    double lng = 0.0;
    if (user['ordinate'] != null) {
      lat = (user['ordinate']['latitude'] ?? 0.0).toDouble();
      lng = (user['ordinate']['longitude'] ?? 0.0).toDouble();
    }
    latController = TextEditingController(text: lat.toString());
    lngController = TextEditingController(text: lng.toString());
    latController = TextEditingController(text: lat.toString());
    lngController = TextEditingController(text: lng.toString());
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLat: double.tryParse(latController.text),
          initialLng: double.tryParse(lngController.text),
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        latController.text = result['latitude'].toString();
        lngController.text = result['longitude'].toString();
      });
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isLoading = true);

    try {
      final updatedData = {
        "phoneNumber": widget.currentUser['phoneNumber'], // Key for identification
        "role": "DOCTOR", // Ensure role is sent
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "hospitalName": hospitalNameController.text.trim(),
        "specialization": specializationController.text.trim(),
        "about": aboutController.text.trim(),
        "address": addressController.text.trim(),
        "degree": degreeController.text.trim(),
        "experience": experienceController.text.trim(),
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
        Navigator.pop(context, response['user']); // Return updated user
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
                _buildTextField("Hospital Name", hospitalNameController),
                _buildTextField("Specialization", specializationController),
                _buildTextField("Degree", degreeController),
                _buildTextField("Experience (Years)", experienceController),
                _buildTextField("Gender", genderController),
                _buildTextField("Address", addressController, maxLines: 3),
                
                Row(
                  children: [
                    Expanded(child: _buildTextField("Latitude", latController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField("Longitude", lngController)),
                  ],
                ),
                
                ElevatedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.map),
                  label: const Text("Pick from Map"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField("About", aboutController, maxLines: 3),
                
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : save,
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Save Changes"),
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
