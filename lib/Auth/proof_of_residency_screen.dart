// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import "complete_profile_screen.dart";

class ProofOfResidencyScreen extends StatefulWidget {
  const ProofOfResidencyScreen({super.key});

  @override
  State<ProofOfResidencyScreen> createState() => _ProofOfResidencyScreenState();
}

class _ProofOfResidencyScreenState extends State<ProofOfResidencyScreen> {
  int _selectedMethod = 0;
  String _selectedCountry = 'United States';
  String _selectedFlag = '🇺🇸';
  XFile? _pickedImage;
  bool _isLoading = false;
  final List<Map<String, String>> _countries = [
    {'name': 'United States', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'Nigeria', 'flag': '🇳🇬'},
    {'name': 'Canada', 'flag': '🇨🇦'},
  ];
  final List<_VerificationMethod> _methods = [
    _VerificationMethod(
      name: 'National Identity Card',
      icon: Icons.badge,
    ),
    _VerificationMethod(
      name: 'Passport',
      customIcon: const Iconify(Tabler.e_passport, size: 32, color: Colors.blue),
    ),
    _VerificationMethod(
      name: 'Driver License',
      icon: Icons.credit_card,
    ),
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _submitProof() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a document image.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not logged in');
      final methodName = _methods[_selectedMethod].name.replaceAll(' ', '_');
      final supabase = Supabase.instance.client;
      final fileBytes = await _pickedImage!.readAsBytes();
      String sanitizeFileName(String fileName) {
        // Replace spaces and commas with underscores, remove other problematic characters
        return fileName.replaceAll(RegExp(r'[\\s,]'), '_').replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');
      }
      final rawFileName = '${DateTime.now().millisecondsSinceEpoch}_${_pickedImage!.name}';
      final fileName = sanitizeFileName(rawFileName);
      final filePath = '$methodName/${user.uid}/$fileName';
      await supabase.storage
          .from('proof-of-residency')
          .uploadBinary(filePath, fileBytes);

      final proofUrl = supabase.storage
          .from('proof-of-residency')
          .getPublicUrl(filePath);
      await FirestoreService().updateUserProfile(user.uid, {
        'residencyProof': proofUrl,
        'residencyProofType': _methods[_selectedMethod].name,
        'residencyCountry': _selectedCountry,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proof of residency uploaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Proof of Residency 🗺️',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prove you live in United States.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            const Text(
              'Nationality',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Text(_selectedFlag, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCountry,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await showModalBottomSheet<Map<String, String>>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return ListView(
                            shrinkWrap: true,
                            children: _countries.map((country) {
                              return ListTile(
                                leading: Text(country['flag']!, style: const TextStyle(fontSize: 24)),
                                title: Text(country['name']!),
                                onTap: () => Navigator.pop(context, country),
                              );
                            }).toList(),
                          );
                        },
                      );
                      if (result != null) {
                        setState(() {
                          _selectedCountry = result['name']!;
                          _selectedFlag = result['flag']!;
                        });
                      }
                    },
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Verification Method',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ..._methods.asMap().entries.map((entry) {
              final idx = entry.key;
              final method = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedMethod == idx
                        ? Colors.blue
                        : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  leading: method.customIcon ?? (method.svgAsset != null
                          ? SvgPicture.asset(method.svgAsset!, height: 32, width: 32)
                          : Icon(method.icon, color: Colors.blue, size: 32)),
                  title: Text(
                    method.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Radio<int>(
                    value: idx,
                    groupValue: _selectedMethod,
                    activeColor: Colors.blue,
                    onChanged: (val) {
                      setState(() => _selectedMethod = val!);
                    },
                ),
                  onTap: () => setState(() => _selectedMethod = idx),
                ),
              );
            }),
            const Spacer(),
            if (_pickedImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.blue, size: 20),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_pickedImage!.name, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_pickedImage == null) {
                          await _pickImage();
                          if (_pickedImage == null) return;
                        }
                        await _submitProof();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _VerificationMethod {
  final String name;
  final IconData? icon;
  final String? svgAsset;
  final Widget? customIcon;
  _VerificationMethod(
      {required this.name, this.icon, this.svgAsset, this.customIcon});
}
