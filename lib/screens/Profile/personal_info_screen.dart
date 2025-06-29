// ignore_for_file: use_super_parameters, unused_element, curly_braces_in_flow_control_structures, unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;
  bool _isEditMode = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Other'];

  File? _pickedImageFile;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not logged in.';
          _isLoading = false;
        });
        return;
      }
      final data = await FirestoreService().getUserProfile(user.uid);
      setState(() {
        _userData = data;
        _isLoading = false;
      });
      if (data != null) {
        _nameController.text = data["displayName"] ?? '';
        _nationalIdController.text = data["nationalId"] ?? '';
        _emailController.text = data["email"] ?? '';
        _phoneController.text = data["phoneNumber"] ?? '';
        _dobController.text = data["dob"] ?? '';
        _genderController.text = data["gender"] ?? '';
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load user data.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirestoreService().updateUserProfile(user.uid, {
        'displayName': _nameController.text.trim(),
        'nationalId': _nationalIdController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'gender': _genderController.text.trim(),
      });
      await _fetchUserData();
      setState(() {
        _isEditMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to update profile.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      if (_userData != null) {
        _nameController.text = _userData!["displayName"] ?? '';
        _nationalIdController.text = _userData!["nationalId"] ?? '';
        _emailController.text = _userData!["email"] ?? '';
        _phoneController.text = _userData!["phoneNumber"] ?? '';
        _dobController.text = _userData!["dob"] ?? '';
        _genderController.text = _userData!["gender"] ?? '';
      }
    });
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isNotEmpty
          ? DateTime.tryParse(_dobController.text) ?? DateTime(2000)
          : DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
      });
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_pickedImageFile == null) return;
    setState(() {
      _isUploadingImage = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final supabase = Supabase.instance.client;
      final fileBytes = await _pickedImageFile!.readAsBytes();
      String fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadRes = await supabase.storage
          .from('profile-pictures')
          .uploadBinary(fileName, fileBytes,
              fileOptions: const FileOptions(upsert: true));
      if (uploadRes.isEmpty) throw Exception('Upload failed');
      final url =
          supabase.storage.from('profile-pictures').getPublicUrl(fileName);
      await FirestoreService().updateUserProfile(user.uid, {'photoURL': url});
      setState(() {
        if (_userData != null) _userData!["photoURL"] = url;
        _pickedImageFile = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture updated!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to upload image.'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Personal Info',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _userData == null
                  ? const Center(child: Text('No user data found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                _buildProfileAvatar(),
                                if (_isEditMode)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: _isUploadingImage
                                          ? null
                                          : _pickProfileImage,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2563EB),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: _isUploadingImage
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const Icon(Icons.edit,
                                                color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                if (!_isEditMode)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2563EB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit,
                                          color: Colors.white, size: 22),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildLabel('Full Name'),
                            _isEditMode
                                ? _buildValidatedTextField(
                                    _nameController, 'Full Name',
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Required'
                                            : null)
                                : _buildValue(
                                    _userData!["displayName"] ?? 'N/A'),
                            const SizedBox(height: 16),
                            _buildLabel('National ID Number'),
                            _isEditMode
                                ? _buildValidatedTextField(
                                    _nationalIdController, 'National ID Number',
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Required'
                                            : null)
                                : _buildValue(
                                    _userData!["nationalId"] ?? 'N/A'),
                            const SizedBox(height: 16),
                            _buildLabel('Email'),
                            _isEditMode
                                ? _buildValidatedTextField(
                                    _emailController, 'Email',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Required';
                                    final emailRegex =
                                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+ ');
                                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+ ')
                                        .hasMatch(v)) return 'Invalid email';
                                    return null;
                                  })
                                : _buildValue(_userData!["email"] ?? 'N/A',
                                    icon: Icons.email_outlined),
                            const SizedBox(height: 16),
                            _buildLabel('Phone Number'),
                            _isEditMode
                                ? _buildValidatedTextField(
                                    _phoneController, 'Phone Number',
                                    keyboardType: TextInputType.phone,
                                    validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Required';
                                    if (!RegExp(r'^[0-9+\-\s]{7,} ')
                                        .hasMatch(v)) return 'Invalid phone';
                                    return null;
                                  })
                                : _buildPhoneRow(
                                    _userData!["phoneNumber"] ?? 'N/A'),
                            const SizedBox(height: 16),
                            _buildLabel('Date of Birth'),
                            _isEditMode
                                ? _buildDatePickerField(
                                    _dobController, 'Date of Birth',
                                    onTap: _pickDate)
                                : _buildValue(_userData!["dob"] ?? 'N/A',
                                    icon: Icons.calendar_today_outlined),
                            const SizedBox(height: 16),
                            _buildLabel('Gender'),
                            _isEditMode
                                ? _buildGenderDropdown(
                                    _genderController, _genders)
                                : _buildValue(_userData!["gender"] ?? 'N/A',
                                    icon: Icons.arrow_drop_down),
                            if (_isEditMode) ...[
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Save'),
                                  ),
                                  OutlinedButton(
                                    onPressed: _cancelEdit,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2563EB),
                                      side: const BorderSide(
                                          color: Color(0xFF2563EB)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    ImageProvider imageProvider;
    if (_pickedImageFile != null) {
      imageProvider = FileImage(_pickedImageFile!);
    } else {
      final url =
          _userData != null ? _userData!["photoURL"]?.toString() ?? '' : '';
      if (url.startsWith('http')) {
        imageProvider = NetworkImage(url);
      } else {
        imageProvider = const AssetImage('assets/profile.jpg');
      }
    }
    return CircleAvatar(
      radius: 56,
      backgroundImage: imageProvider,
      onBackgroundImageError: (_, __) {},
    );
  }
}

Widget _buildLabel(String label) => Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ),
    );

Widget _buildValue(String value, {IconData? icon}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2563EB), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (icon != null) Icon(icon, color: Colors.black54),
        ],
      ),
    );

Widget _buildPhoneRow(String phoneNumber) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2563EB), width: 1)),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text('🇺🇸', style: TextStyle(fontSize: 22)),
          ),
          Text(
            phoneNumber,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.phone_outlined, color: Colors.black54),
        ],
      ),
    );

Widget _buildTextField(TextEditingController controller, String label,
        {TextInputType keyboardType = TextInputType.text}) =>
    Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2563EB), width: 1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );

Widget _buildValidatedTextField(TextEditingController controller, String label,
        {TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator}) =>
    Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2563EB), width: 1)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        validator: validator,
      ),
    );

Widget _buildDatePickerField(TextEditingController controller, String label,
        {required VoidCallback onTap}) =>
    Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2563EB), width: 1)),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          suffixIcon:
              const Icon(Icons.calendar_today_outlined, color: Colors.black54),
        ),
        onTap: onTap,
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );

Widget _buildGenderDropdown(
        TextEditingController controller, List<String> genders) =>
    Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2563EB), width: 1)),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.text.isNotEmpty && genders.contains(controller.text)
            ? controller.text
            : null,
        items: genders
            .map((g) => DropdownMenuItem(
                value: g,
                child: Text(g,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))))
            .toList(),
        onChanged: (val) {
          controller.text = val ?? '';
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
