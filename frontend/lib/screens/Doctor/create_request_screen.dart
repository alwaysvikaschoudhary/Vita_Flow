import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vita_flow/config.dart';
import 'package:intl/intl.dart';
import 'package:vita_flow/screens/Location/location_picker_screen.dart';

class CreateBloodRequestScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const CreateBloodRequestScreen({super.key, required this.currentUser});

  @override
  State<CreateBloodRequestScreen> createState() =>
      _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState extends State<CreateBloodRequestScreen> {
  String selectedBlood = "";
  String urgency = "";
  bool _isLoading = false;
  
  // Location State
  String _locationType = "current"; // "current" or "new"
  final TextEditingController _unitsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  final List<String> bloodTypes = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-"
  ];

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

  Future<void> _createRequest() async {
    if (selectedBlood.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a blood group")),
      );
      return;
    }

    if (_unitsController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter units required")),
      );
      return;
    }

    double latitude = 0.0;
    double longitude = 0.0;

    if (_locationType == "new") {
      if (_latController.text.isEmpty || _lngController.text.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter latitude and longitude")),
        );
        return;
      }
      try {
        latitude = double.parse(_latController.text);
        longitude = double.parse(_lngController.text);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid latitude or longitude")),
        );
        return;
      }
    } else {

      // Use current user location
      if (widget.currentUser['ordinate'] != null) {
        latitude = (widget.currentUser['ordinate']['latitude'] ?? 0.0).toDouble();
        longitude = (widget.currentUser['ordinate']['longitude'] ?? 0.0).toDouble();
      } else {
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("No saved location found in profile. Please select 'New Location' or update profile.")),
         );
         return;
      }
      
      if (latitude == 0.0 && longitude == 0.0) {
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Invalid saved location (0,0). Please update profile.")),
         );
         return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> requestBody = {
      "bloodGroup": selectedBlood,
      "units": _unitsController.text,
      "urgency": urgency,
      "status": "PENDING",
      "hospitalId": widget.currentUser['userId'], 
      "doctorName": widget.currentUser['name'],
      "time": DateFormat('HH:mm').format(DateTime.now()),
      "date": DateFormat('dd-MM-yyyy').format(DateTime.now()),
      "ordinate": {
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request created successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create request: ${response.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Blood Request",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      Text("Fill in the details below",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              // BLOOD TYPE CARD
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Blood Type Required",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: bloodTypes.map((type) {
                        final isSelected = selectedBlood == type;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedBlood = type;
                            });
                          },
                          child: Container(
                            width: 70,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color:
                                  isSelected ? Colors.red.shade50 : Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.red : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // UNITS REQUIRED
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Units Required",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _unitsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "units",
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // URGENCY LEVEL
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Urgency Level",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Low
                    _urgencyTile("Low"),
                    const SizedBox(height: 10),

                    // Medium
                    _urgencyTile("Medium", highlight: true),
                    const SizedBox(height: 10),

                    // Critical
                    _urgencyTile("Critical", subtitle: "Within 1 hours"),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // LOCATION
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Location",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Radio<String>(
                          value: "current",
                          groupValue: _locationType,
                          onChanged: (val) {
                            setState(() {
                              _locationType = val!;
                            });
                          },
                          activeColor: Colors.red,
                        ),
                        const Text("Your Location"),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: "new",
                          groupValue: _locationType,
                          onChanged: (val) {
                            setState(() {
                              _locationType = val!;
                            });
                          },
                          activeColor: Colors.red,
                        ),
                        const Text("New Location"),
                      ],
                    ),
                    if (_locationType == "current") ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Saved Address:",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.currentUser['address'] ?? "No address saved",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            if (widget.currentUser['ordinate'] != null)
                              Text(
                                "Coordinates: ${widget.currentUser['ordinate']['latitude']}, ${widget.currentUser['ordinate']['longitude']}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade500),
                              )
                            else
                              const Text(
                                "No location coordinates found. Please update your profile.",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (_locationType == "new") ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _latController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Latitude",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _lngController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Longitude",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _pickLocation,
                        icon: const Icon(Icons.map),
                        label: const Text("Pick from Map"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BUTTON
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
                  onPressed: _isLoading ? null : _createRequest,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Create Request",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                ),
              ),
            ],
          ),
        ),
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
      ),
      child: child,
    );
  }

  // URGENCY SELECTOR TILE
  Widget _urgencyTile(String level, {bool highlight = false, String? subtitle}) {
    final isSelected = urgency == level;

    return GestureDetector(
      onTap: () {
        setState(() {
          urgency = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.red : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? Colors.red.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
              color: isSelected ? Colors.red : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              level,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.red : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
