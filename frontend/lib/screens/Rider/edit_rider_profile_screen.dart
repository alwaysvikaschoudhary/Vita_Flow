import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Location/location_picker_screen.dart';

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
  late TextEditingController latController;
  late TextEditingController lngController;
  
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
    
    double lat = 0.0;
    double lng = 0.0;
    if (widget.currentUser['ordinate'] != null) {
      lat = (widget.currentUser['ordinate']['latitude'] ?? 0.0).toDouble();
      lng = (widget.currentUser['ordinate']['longitude'] ?? 0.0).toDouble();
    }
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
        "ordinate": {
          "latitude": double.tryParse(latController.text) ?? 0.0,
          "longitude": double.tryParse(lngController.text) ?? 0.0,
        }
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
