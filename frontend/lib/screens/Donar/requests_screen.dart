import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vita_flow/config.dart';
import 'package:vita_flow/screens/Common/location_picker_screen.dart';
import 'package:intl/intl.dart';

class RequestsScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const RequestsScreen({super.key, required this.currentUser});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  // Form State
  String selectedBlood = "";
  bool _isLoading = false;
  
  // Toggle States
  String _locationType = "current"; // "current" | "new"
  String _nameType = "current"; // "current" | "new"
  String _phoneType = "current"; // "current" | "new"

  // Controllers
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<String> bloodTypes = [
    "A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"
  ];

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLat: double.tryParse(_latController.text),
          initialLng: double.tryParse(_lngController.text),
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _latController.text = result['latitude'].toString();
        _lngController.text = result['longitude'].toString();
      });
    }
  }

  Future<void> _submitRequest() async {
    // Validation
    if (selectedBlood.isEmpty) {
      _showSnack("Please select a blood group");
      return;
    }

    double latitude = 0.0;
    double longitude = 0.0;

    // Location Logic
    if (_locationType == "new") {
      if (_latController.text.isEmpty || _lngController.text.isEmpty) {
        _showSnack("Please enter latitude and longitude");
        return;
      }
      try {
        latitude = double.parse(_latController.text);
        longitude = double.parse(_lngController.text);
      } catch (e) {
        _showSnack("Invalid coordinates");
        return;
      }
    } else {
       if (widget.currentUser['ordinate'] != null) {
        latitude = (widget.currentUser['ordinate']['latitude'] ?? 0.0).toDouble();
        longitude = (widget.currentUser['ordinate']['longitude'] ?? 0.0).toDouble();
      } else {
        _showSnack("No saved location found in profile.");
        return;
      }
    }

    // Name Logic
    String donorName = widget.currentUser['name'] ?? "Unknown";
    if (_nameType == "new") {
      if (_nameController.text.trim().isEmpty) {
        _showSnack("Please enter donor name");
        return;
      }
      donorName = _nameController.text.trim();
    }

    // Phone Logic
    String donorPhone = widget.currentUser['phoneNumber'] ?? "";
    if (_phoneType == "new") {
      if (_phoneController.text.trim().isEmpty) {
        _showSnack("Please enter donor phone number");
        return;
      }
      donorPhone = _phoneController.text.trim();
    }

    setState(() => _isLoading = true);

    // Construct Payload
    final Map<String, dynamic> requestBody = {
      "bloodGroup": selectedBlood,
      "units": "1", // Fixed
      "urgency": "Low", // Fixed
      "status": "PENDING", // Fixed
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()), // Today
      "time": DateFormat('HH:mm').format(DateTime.now()),
      "donorId": widget.currentUser['userId'] ?? widget.currentUser['id'],
      "donorName": donorName,
      "donorPhoneNumber": donorPhone,
      "hospitalId": null,
      "doctorName": null,
      "riderId": null,
      "pickupOrdinate": {
        "latitude": latitude, 
        "longitude": longitude
      }
    };

    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/request/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _showSnack("Donation Request Sent Successfully!");
        // Reset form or navigate away? 
        // User didn't specify, staying on screen or resetting is safe.
        setState(() {
          _locationType = "current";
          _nameType = "current";
          _phoneType = "current";
          _latController.clear();
          _lngController.clear();
          _nameController.clear();
          _phoneController.clear();
        });
      } else {
        _showSnack("Failed: ${response.body}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Donate Blood",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Fill details to create a donation request",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BLOOD TYPE
              _sectionTitle("Allot Blood Group"),
              _card(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: bloodTypes.map((type) {
                    final isSelected = selectedBlood == type;
                    return GestureDetector(
                      onTap: () => setState(() => selectedBlood = type),
                      child: Container(
                        width: 70,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red.shade50 : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.red : Colors.grey.shade300
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.red : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // LOCATION
              _sectionTitle("Pickup Location"),
              _card(
                child: Column(
                  children: [
                    _radioOption(
                      title: "Use My Location",
                      value: "current",
                      groupValue: _locationType,
                      onChanged: (v) => setState(() => _locationType = v!),
                    ),
                    if (_locationType == "current")
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          widget.currentUser['address'] ?? "No address saved",
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                      ),
                    _radioOption(
                      title: "Select New Location",
                      value: "new",
                      groupValue: _locationType,
                      onChanged: (v) => setState(() => _locationType = v!),
                    ),
                    if (_locationType == "new") ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _textField(_latController, "Latitude")),
                          const SizedBox(width: 10),
                          Expanded(child: _textField(_lngController, "Longitude")),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _pickLocation,
                        icon: const Icon(Icons.map, color: Colors.white, size: 18),
                        label: const Text("Pick from Map", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DONOR NAME
              _sectionTitle("Donor Name"),
              _card(
                child: Column(
                  children: [
                    _radioOption(
                      title: "My Name (${widget.currentUser['name']})",
                      value: "current",
                      groupValue: _nameType,
                      onChanged: (v) => setState(() => _nameType = v!),
                    ),
                    _radioOption(
                      title: "Enter New Name",
                      value: "new",
                      groupValue: _nameType,
                      onChanged: (v) => setState(() => _nameType = v!),
                    ),
                    if (_nameType == "new")
                      _textField(_nameController, "Full Name"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DONOR NUMBER
              _sectionTitle("Donor Number"),
              _card(
                child: Column(
                  children: [
                    _radioOption(
                      title: "My Number (${widget.currentUser['phoneNumber']})",
                      value: "current",
                      groupValue: _phoneType,
                      onChanged: (v) => setState(() => _phoneType = v!),
                    ),
                    _radioOption(
                      title: "Enter New Number",
                      value: "new",
                      groupValue: _phoneType,
                      onChanged: (v) => setState(() => _phoneType = v!),
                    ),
                    if (_phoneType == "new")
                      _textField(_phoneController, "Phone Number", keyboardType: TextInputType.phone),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0463A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitRequest,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Donation Request",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _radioOption({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: const Color(0xFFE0463A),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _textField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
