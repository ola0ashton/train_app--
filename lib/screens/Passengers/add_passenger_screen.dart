// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPassengerScreen extends StatefulWidget {
  final String? passengerId;
  final Map<String, dynamic>? initialData;
  const AddPassengerScreen({Key? key, this.passengerId, this.initialData})
      : super(key: key);

  @override
  State<AddPassengerScreen> createState() => _AddPassengerScreenState();
}

class _AddPassengerScreenState extends State<AddPassengerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  String _idType = 'ID Card';
  String _gender = 'Male';
  DateTime? _birthdate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void didUpdateWidget(covariant AddPassengerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['fullName'] ?? '';
      _idNumberController.text = widget.initialData!['idNumber'] ?? '';
      _idType = widget.initialData!['idType'] ?? 'ID Card';
      _gender = widget.initialData!['gender'] ?? 'Male';
      if (widget.initialData!['birthdate'] != null) {
        _birthdate = DateTime.tryParse(widget.initialData!['birthdate']);
      }
    } else {
      _nameController.clear();
      _idNumberController.clear();
      _idType = 'ID Card';
      _gender = 'Male';
      _birthdate = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _savePassenger() async {
    if (!_formKey.currentState!.validate() || _birthdate == null) return;
    setState(() {
      _isSaving = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final passengerData = {
        'fullName': _nameController.text.trim(),
        'idType': _idType,
        'idNumber': _idNumberController.text.trim(),
        'gender': _gender,
        'birthdate': _birthdate!.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (widget.passengerId != null) {
        // Edit mode
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('passengers')
            .doc(widget.passengerId)
            .update(passengerData);
      } else {
        // Add mode
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('passengers')
            .add({
          ...passengerData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save passenger: $e')),
      );
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
        title: const Text('Add New Passenger',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              const Text('Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter full name',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter name' : null,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ID Type',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButtonFormField<String>(
                          value: _idType,
                          items: const [
                            DropdownMenuItem(
                                value: 'ID Card', child: Text('ID Card')),
                            DropdownMenuItem(
                                value: 'Passport', child: Text('Passport')),
                            DropdownMenuItem(
                                value: 'Driver License',
                                child: Text('Driver License')),
                          ],
                          onChanged: (v) =>
                              setState(() => _idType = v ?? 'ID Card'),
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ID Number',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextFormField(
                          controller: _idNumberController,
                          decoration: const InputDecoration(
                            hintText: 'Enter ID number',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter ID number'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              const Text('Gender',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gender == 'Male'
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        foregroundColor: _gender == 'Male'
                            ? Colors.white
                            : const Color(0xFF2563EB),
                        side: BorderSide(color: const Color(0xFF2563EB)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => setState(() => _gender = 'Male'),
                      child: const Text('Male'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gender == 'Female'
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        foregroundColor: _gender == 'Female'
                            ? Colors.white
                            : const Color(0xFF2563EB),
                        side: BorderSide(color: const Color(0xFF2563EB)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => setState(() => _gender = 'Female'),
                      child: const Text('Female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Birthdate',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _birthdate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        _birthdate == null
                            ? 'Select birthdate'
                            : '${_birthdate!.day.toString().padLeft(2, '0')}-${_birthdate!.month.toString().padLeft(2, '0')}-${_birthdate!.year}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today_outlined, size: 22),
                    ],
                  ),
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isSaving ? null : _savePassenger,
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
