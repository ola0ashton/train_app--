// ignore_for_file: deprecated_member_use, use_super_parameters, prefer_const_constructors, dead_code, unused_label, unnecessary_const, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_pin_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
// The following import is only valid for web builds. Ignore analyzer warning in mobile/desktop.
// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;


class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedImage;
  String? _uploadedImageUrl;
  bool _uploadingProfileImage = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;

  bool _isLoading = false;

  String _countryCode = '+1';
  String _countryFlag = '🇺🇸';

  final List<Map<String, String>> _countries = [
    {'flag': '🇺🇸', 'code': '+1', 'name': 'United States'},
    {'flag': '🇬🇧', 'code': '+44', 'name': 'United Kingdom'},
    {'flag': '🇳🇬', 'code': '+234', 'name': 'Nigeria'},
    {'flag': '🇮🇳', 'code': '+91', 'name': 'India'},
    {'flag': '🇨🇦', 'code': '+1', 'name': 'Canada'},
    // Add more as needed
  ];

  Future<void> _pickProfileImage() async {
  if (kIsWeb) {
    // Web: use html.FileUploadInputElement
    // final uploadInput = html.FileUploadInputElement();
    // final reader = html.FileReader();
    return;
  } else {
    // Android/iOS
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _uploadingProfileImage = true;
      });
      try {
        final supabase = Supabase.instance.client;
        final fileBytes = await picked.readAsBytes();
        final fileName = 'profile_images/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
        await supabase.storage.from('profile-images').uploadBinary(fileName, fileBytes);
        final imageUrl = supabase.storage.from('profile-images').getPublicUrl(fileName);
        setState(() {
          _pickedImage = picked;
          _uploadedImageUrl = imageUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      } finally {
        setState(() {
          _uploadingProfileImage = false;
        });
      }
    }
  }
}


  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectCountryCode() async {
    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) {
        return ListView(
          children: _countries.map((country) {
            return ListTile(
              leading: Text(country['flag']!, style: const TextStyle(fontSize: 20, fontFamily: 'Urbanist')),
              title: Text('${country['name']} (${country['code']})', style: const TextStyle(fontFamily: 'Urbanist')),
              onTap: () => Navigator.of(context).pop(country),
            );
          }).toList(),
        );
      },
    );
    if (selected != null) {
      setState(() {
        _countryFlag = selected['flag']!;
        _countryCode = selected['code']!;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.', style: TextStyle(fontFamily: 'Urbanist'))),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not logged in');
      String? photoUrl = _uploadedImageUrl;
      // If new image picked, upload to Supabase
      if (_pickedImage != null) {
        final supabase = Supabase.instance.client;
        final fileBytes = await _pickedImage!.readAsBytes();
        String sanitizeFileName(String fileName) {
          return fileName.replaceAll(RegExp(r'[\\s,]'), '_').replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');
        }
        final rawFileName = '${DateTime.now().millisecondsSinceEpoch}_${_pickedImage!.name}';
        final fileName = sanitizeFileName(rawFileName);
        final filePath = 'profile-images/${user.uid}/$fileName';
        await supabase.storage.from('profile-images').uploadBinary(filePath, fileBytes);
        photoUrl = supabase.storage.from('profile-images').getPublicUrl(filePath);
        _uploadedImageUrl = photoUrl;
      }
      final profileData = {
        'displayName': _nameController.text.trim(),
        'nationalId': _idController.text.trim(),
        'phone': '$_countryCode${_phoneController.text.trim()}',
        'dob': _selectedDate!.toIso8601String(),
        'countryCode': _countryCode,
        'countryFlag': _countryFlag,
        'updatedAt': DateTime.now(),
        'photoURL': photoUrl,
      };
      await FirestoreService().updateUserProfile(user.uid, profileData);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CreatePinScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainScaffold = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 1.0, // Full progress
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Row(
                children: [
                  Text(
                    'Complete your profile ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.assignment,
                    color: Color(0xFF2962FF),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Please enter your profile. Don't worry, only you can see your personal data. No one else will be able to see it.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: const Color(0xFFF2F2F2),
                      backgroundImage: _pickedImage != null
                          ? FileImage(File(_pickedImage!.path))
                          : (_uploadedImageUrl != null ? NetworkImage(_uploadedImageUrl!) : null) as ImageProvider?,
                      child: (_pickedImage == null && _uploadedImageUrl == null)
                          ? const Icon(Icons.person, size: 70, color: Colors.grey)
                          : null,
                    ),
                    if (_uploadingProfileImage)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color(0x88000000),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2962FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Urbanist')),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Full Name',
                        hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Urbanist'),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('National ID Number', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Urbanist')),
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        hintText: 'National ID Number',
                        hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Urbanist'),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter your ID number' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Urbanist')),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _selectCountryCode,
                          child: Row(
                            children: [
                              Text(_countryFlag, style: const TextStyle(fontSize: 20, fontFamily: 'Urbanist')),
                              const SizedBox(width: 4),
                              Text(_countryCode, style: const TextStyle(fontSize: 16, fontFamily: 'Urbanist')),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '000 000 000',
                              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Urbanist'),
                              suffixIcon: Icon(Icons.call, color: Colors.grey),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Enter your phone number' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Urbanist')),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: _selectedDate == null
                                ? 'Date of Birth'
                                : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                            hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Urbanist'),
                            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                          ),
                          validator: (value) {
                            if (_selectedDate == null) {
                              return 'Select your date of birth';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text('Continue', style: TextStyle(fontSize: 18, fontFamily: 'Urbanist')),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
    if (_isLoading) {
      return Stack(
        children: [
          mainScaffold,
          Opacity(
            opacity: 0.6,
            child: const ModalBarrier(dismissible: false, color: Colors.black),
          ),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    } else {
      return mainScaffold;
    }
  }
}
