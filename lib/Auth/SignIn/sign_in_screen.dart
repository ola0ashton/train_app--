// ignore_for_file: use_super_parameters, unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../signup_screen.dart';
import '../ForgotPassword/forgot_password_screen.dart';
import 'package:lottie/lottie.dart';
import '../../screens/Home/home_screen.dart';
import '../../screens/Security/sms_mfa_verify_screen.dart';
import '../../screens/Security/totp_verify_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:train_app/screens/onboarding_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  void _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/train_loading.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Signing In...',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final user = userCredential.user;
        if (user != null) {
          // Check Firestore for user document
          final userDoc = await FirestoreService().getUserProfile(user.uid);

          // Simulate a slight delay to show loading animation
          await Future.delayed(const Duration(seconds: 2));

          // Dismiss loading dialog
          Navigator.of(context).pop();

          if (userDoc != null) {
            // --- MFA Integration ---
            final mfaSms = userDoc['smsAuth'] == true;
            final mfaGoogle = userDoc['googleAuth'] == true;
            bool mfaPassed = true;
            // 1. SMS MFA
            if (mfaSms) {
              String? verificationId;
              final phone = userDoc['mfaPhone'];
              if (phone == null || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('No phone number set for SMS MFA.')),
                );
                return;
              }
              bool smsVerified = false;
              await FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: phone,
                verificationCompleted:
                    (PhoneAuthCredential credential) async {},
                verificationFailed: (FirebaseAuthException e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('SMS verification failed: \\${e.message}')),
                  );
                },
                codeSent: (String vId, int? resendToken) async {
                  verificationId = vId;
                  final verified = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SmsMfaVerifyScreen(
                            phone: phone, verificationId: verificationId!),
                      ));
                  if (verified == true) {
                    smsVerified = true;
                  }
                },
                codeAutoRetrievalTimeout: (String vId) {
                  verificationId = vId;
                },
              );
              if (!smsVerified) return;
            }
            // 2. Google Authenticator (TOTP)
            if (mfaGoogle) {
              final secret = userDoc['totpSecret'];
              if (secret == null || secret.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('No TOTP secret set for Google Authenticator.')),
                );
                return;
              }
              final verified = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TotpVerifyScreen(secret: secret),
                  ));
              if (verified != true) return;
            }
            // --- End MFA Integration ---
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            await FirebaseAuth.instance.signOut();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: const Text('User does not exist in the database.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // Dismiss loading dialog if it's still open
        Navigator.of(context).pop();

        String errorMessage = 'Sign in failed';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _signInWithGoogle() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Navigator.of(context).pop();
        return; // User cancelled
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        // Optionally create user doc in Firestore if needed
        await FirestoreService().createUserDocument(user);
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in failed.')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in error: $e')),
      );
    }
  }

  void _signInWithApple() async {
    // TODO: Implement Apple sign-in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple sign-in not yet implemented.')),
    );
  }

  void _signInWithFacebook() async {
    // TODO: Implement Facebook sign-in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook sign-in not yet implemented.')),
    );
  }

  void _signInWithTwitter() async {
    // TODO: Implement Twitter sign-in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Twitter sign-in not yet implemented.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2962FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const OnboardingPage()),
            );
          },
        ),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    'Welcome back ',
                    style: GoogleFonts.urbanist(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text('👋', style: GoogleFonts.urbanist(fontSize: 28)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Please enter your email & password to sign in.',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email',
                        style:
                            GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: GoogleFonts.urbanist(color: Colors.grey),
                        suffixIcon: Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: const Icon(Icons.mail_outline,
                              color: Colors.black54),
                        ),
                        border: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF2962FF), width: 2),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your email'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text('Password',
                        style:
                            GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: GoogleFonts.urbanist(color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.blue),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        border: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF2962FF), width: 2),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your password'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: const Color(0xFF2962FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    onChanged: (value) =>
                        setState(() => _rememberMe = value ?? false),
                  ),
                  Text('Remember me', style: GoogleFonts.urbanist()),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(thickness: 1, height: 1),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text('Forgot password?',
                      style: GoogleFonts.urbanist(
                          color: const Color(0xFF2962FF),
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: GoogleFonts.urbanist()),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Text('Sign up',
                        style: GoogleFonts.urbanist(
                            color: const Color(0xFF2962FF),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('or continue with',
                        style: GoogleFonts.urbanist(color: Colors.black54)),
                  ),
                  const Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _signInWithGoogle,
                    child: const _SocialButton(
                        icon: FontAwesomeIcons.google, color: Colors.red),
                  ),
                  GestureDetector(
                    onTap: _signInWithApple,
                    child: const _SocialButton(
                        icon: FontAwesomeIcons.apple, color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: _signInWithFacebook,
                    child: const _SocialButton(
                        icon: FontAwesomeIcons.facebook,
                        color: Color(0xFF1877F3)),
                  ),
                  GestureDetector(
                    onTap: _signInWithTwitter,
                    child: const _SocialButton(
                        icon: FontAwesomeIcons.twitter,
                        color: Color(0xFF1DA1F2)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _signInWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SocialButton({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color, size: 28),
    );
  }
}
