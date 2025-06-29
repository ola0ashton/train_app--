// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

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
        title: const Text('Privacy Policy',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'At Yemitrain, we respect and protect the privacy of our users. This Privacy Policy outlines the types of personal information we collect, how we use it, and how we protect your information.',
              style:
                  TextStyle(fontSize: 17, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Text(
              'Information We Collect',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'When you use our app, we may collect the following types of personal information:',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '\u2022 Device Information: We may collect information about the type of device you use, its operating system, and other technical details to help us improve our app.\n'
              '\u2022 Usage Information: We may collect information about how you use our app, such as which features you use and how often you use them.\n'
              '\u2022 Personal Information: We may collect personal information, such as your name, email address, or phone number, if you choose to provide it to us.\n'
              '\u2022 Location Information: With your permission, we may collect and use your device\'s location to provide location-based services, such as finding nearby train stations.',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.7),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Text(
              'How We Use Your Information',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'We use your information for the following purposes:',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '\u2022 To provide and improve our app and services.\n'
              '\u2022 To process your train ticket bookings and payments.\n'
              '\u2022 To communicate with you about your account, bookings, and customer support requests.\n'
              '\u2022 To send you important updates, notifications, and promotional offers (if you opt in).\n'
              '\u2022 To analyze usage trends and improve user experience.',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.7),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Text(
              'How We Share Your Information',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'We do not sell your personal information to third parties. We may share your information in the following circumstances:',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '\u2022 With service providers who help us operate our app and provide services (such as payment processors and customer support).\n'
              '\u2022 When required by law or to protect the rights, property, or safety of Railify, our users, or others.\n'
              '\u2022 With your consent or at your direction.',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.7),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Text(
              'Data Security',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'We take reasonable measures to protect your information from unauthorized access, loss, misuse, or alteration. However, no method of transmission over the internet or electronic storage is 100% secure.',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Text(
              'Your Choices',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'You can update your account information at any time through the app. You may also opt out of receiving promotional communications by following the instructions in those messages.',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Text(
              'Children\'s Privacy',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Railify does not knowingly collect personal information from children under the age of 13. If you believe we have collected such information, please contact us so we can remove it.',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Text(
              'Changes to This Policy',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting the new policy in the app.',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Text(
              'Contact Us',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'If you have any questions or concerns about this Privacy Policy, please contact us at support@railify.com.',
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
