import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'proof_of_residency_screen.dart';

class VerifyIdentityScreen extends StatelessWidget {
  const VerifyIdentityScreen({super.key});
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
                widthFactor: 0.66, // 2/3 progress
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
            const SizedBox(height: 40),
            const Text(
              "Let's verify your identity",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.credit_card, size: 32, color: Colors.black87),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'We want to confirm your identity before you can use our service.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: SvgPicture.asset(
                    'assets/images/Frame.svg',
                    height: 600,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) => const ProofOfResidencyScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final fadeAnim = animation.drive(
                          Tween<double>(begin: 0.0, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeIn)),
                        );
                        final scaleAnim = animation.drive(
                          Tween<double>(begin: 0.8, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeOutBack)),
                        );
                        return FadeTransition(
                          opacity: fadeAnim,
                          child: ScaleTransition(scale: scaleAnim, child: child),
                        );
                      },
                    ),
                  );
                },
                child: const Text(
                  'Let\'s Verify',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
