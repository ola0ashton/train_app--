// ignore_for_file: unused_field, unused_element, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'SignIn/sign_in_screen.dart';
import 'verify_identity_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _isPasswordVisible = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  Future<void> _signUpWithEmailAndPassword() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the terms and privacy policy.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Use the AuthService to handle signup and Firestore operations
      UserCredential userCredential = await _authService.signUpWithEmailAndPassword(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      
      print('User created: ${userCredential.user?.uid}');
      
      if (!mounted) {
        print('Widget not mounted, aborting navigation');
        return;
      }
      
      print('Navigating to VerifyIdentityScreen...');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VerifyIdentityScreen()),
      );
      print('Navigation triggered');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage = 'Sign up failed';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled in Firebase.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Up Failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('General exception: ${e.toString()}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Up Failed'),
          content: Text('An unexpected error occurred. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
                widthFactor: 0.33,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Hello there ', style: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.bold)),
                            const Text('👋', style: TextStyle(fontSize: 32)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Please enter your email & password to create an account.',
                            style: GoogleFonts.urbanist(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 32),
                        Text('Email', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.email_outlined),
                            suffixIcon: Icon(Icons.check_circle,
                                color: _emailCtrl.text.isNotEmpty && _validateEmail(_emailCtrl.text) == null ? Colors.green : Colors.grey[400]),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 24),
                        Text('Password', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          validator: _validatePassword,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Create a password',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.urbanist(color: Colors.black),
                                  children: const [
                                    TextSpan(text: 'I agree to Railify '),
                                    TextSpan(text: 'Terms & Privacy Policy', style: TextStyle(color: Colors.blue)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account? '),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SignInScreen()),
                              ),
                              child: Text('Sign in', style: GoogleFonts.urbanist(color: Colors.blue)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_agreedToTerms) ? null : _signUpWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Sign Up',
                        style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
