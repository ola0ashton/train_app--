// ignore_for_file: strict_top_level_inference, unused_import, use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'Auth/SignIn/sign_in_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/Home/account_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_page.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({Key? key}) : super(key: key);

  Future<void> _initialize() async {
    // Initialize Firebase only if not already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://alyeeofuhgnaszoggfjf.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFseWVlb2Z1aGduYXN6b2dnZmpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxMDA2MzAsImV4cCI6MjA2MTY3NjYzMH0.HX-VoFd2mUFDX2L4z3MvU8WnJ3gVTnwKW49sk-a6Jd4',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
            create: (_) => ThemeProvider(),
            child: const MyApp(),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error initializing app. Please check your internet connection and try again.\n\nError: \\${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        // Show splash/loading while initializing
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguage');
    debugPrint('Loading saved language: $savedLanguage');
    if (savedLanguage != null) {
      setState(() {
        _locale = _getLocaleFromLanguage(savedLanguage);
        debugPrint(
            'Set initial locale to: ${_locale?.languageCode}_${_locale?.countryCode}');
      });
    }
  }

  Locale _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'English (US)':
        return const Locale('en', 'US');
      case 'English (UK)':
        return const Locale('en', 'GB');
      case 'Spanish':
        return const Locale('es');
      case 'French':
        return const Locale('fr');
      case 'Mandarin':
        return const Locale('zh');
      case 'Arabic':
        return const Locale('ar');
      case 'Bengali':
        return const Locale('bn');
      case 'Russian':
        return const Locale('ru');
      case 'Japanese':
        return const Locale('ja');
      case 'Korean':
        return const Locale('ko');
      case 'Indonesia':
        return const Locale('id');
      default:
        return const Locale('en', 'US');
    }
  }

  void setLocale(Locale locale) {
    debugPrint(
        'setLocale called with: ${locale.languageCode}_${locale.countryCode}');
    setState(() {
      _locale = locale;
      debugPrint(
          'Locale updated to: ${_locale?.languageCode}_${_locale?.countryCode}');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'Building MaterialApp with locale: ${_locale?.languageCode}_${_locale?.countryCode}');
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('es'),
        Locale('fr'),
        Locale('zh'),
        Locale('ar'),
        Locale('bn'),
        Locale('ru'),
        Locale('ja'),
        Locale('ko'),
        Locale('id'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        debugPrint(
            'Resolving locale: ${locale?.languageCode}_${locale?.countryCode}');
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            debugPrint(
                'Found matching locale: ${supportedLocale.languageCode}_${supportedLocale.countryCode}');
            return supportedLocale;
          }
        }
        debugPrint('No matching locale found, using default: en_US');
        return const Locale('en', 'US');
      },
      title: 'Train App',
      theme: context.watch<ThemeProvider>().currentTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF6A11CB)],
          ),
        ),
        child: Stack(
          children: [
            // Radial gradient overlay for depth
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.3),
                    radius: 0.8,
                    colors: [
                      Color(0x40FFFFFF),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isError) ...[
                    // Glassmorphic, glowing, shadowed icon background
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.5),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.12),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        // Glassmorphic effect
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.35),
                                Colors.white.withOpacity(0.10),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.train,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Reflection
                        Positioned(
                          bottom: -60,
                          child: Opacity(
                            opacity: 0.18,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationX(3.14159),
                              child: Container(
                                width: 80,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 44),
                    // Tagline with shadow, centered and professional
                    Text(
                      'Travel Smart. Travel Fast.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Urbanist-Regular',
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 44),
                    // Custom glowing dot progress indicator
                    const _GlowingDotIndicator(),
                  ] else ...[
                    const Icon(
                      Icons.error_outline,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isError = false;
                          _errorMessage = '';
                        });
                        _navigateToHome();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom glowing dot indicator
class _GlowingDotIndicator extends StatefulWidget {
  const _GlowingDotIndicator();

  @override
  State<_GlowingDotIndicator> createState() => _GlowingDotIndicatorState();
}

class _GlowingDotIndicatorState extends State<_GlowingDotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.7),
                  blurRadius: 16 * _animation.value,
                  spreadRadius: 2 * _animation.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
