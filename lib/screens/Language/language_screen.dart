// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  final String? currentLanguage;
  final void Function(Locale) setLocale;
  const LanguageScreen(
      {Key? key, this.currentLanguage, required this.setLocale})
      : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;

  final List<String> _suggested = [
    'English (US)',
    'English (UK)',
  ];
  final List<String> _languages = [
    'Mandarin',
    'Spanish',
    'French',
    'Arabic',
    'Bengali',
    'Russian',
    'Japanese',
    'Korean',
    'Indonesia',
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ??
          widget.currentLanguage ??
          'English (US)';
    });
  }

  Future<void> _selectLanguage(String lang) async {
    debugPrint('Selecting language: $lang');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', lang);
    debugPrint('Saved language to SharedPreferences: $lang');

    setState(() {
      _selectedLanguage = lang;
    });

    Locale locale;
    switch (lang) {
      case 'English (US)':
        locale = const Locale('en', 'US');
        break;
      case 'English (UK)':
        locale = const Locale('en', 'GB');
        break;
      case 'Spanish':
        locale = const Locale('es');
        break;
      case 'French':
        locale = const Locale('fr');
        break;
      case 'Mandarin':
        locale = const Locale('zh');
        break;
      case 'Arabic':
        locale = const Locale('ar');
        break;
      case 'Bengali':
        locale = const Locale('bn');
        break;
      case 'Russian':
        locale = const Locale('ru');
        break;
      case 'Japanese':
        locale = const Locale('ja');
        break;
      case 'Korean':
        locale = const Locale('ko');
        break;
      case 'Indonesia':
        locale = const Locale('id');
        break;
      default:
        locale = const Locale('en', 'US');
    }
    debugPrint(
        'Setting locale to: ${locale.languageCode}_${locale.countryCode}');

    widget.setLocale(locale);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildLanguageTile(String lang) {
    final isSelected = _selectedLanguage == lang;
    return ListTile(
      title: Text(lang,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing:
          isSelected ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
      onTap: () => _selectLanguage(lang),
    );
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
        title: const Text('Language',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text('Suggested',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          ..._suggested.map(_buildLanguageTile),
          const SizedBox(height: 12),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text('Language',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          ..._languages.map(_buildLanguageTile),
        ],
      ),
    );
  }
}
