// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:train_app/services/firestore_service.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<Map<String, dynamic>>> _faqsByCategory = {};
  bool _loading = true;
  String _selectedCategory = 'General';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFaqs();
  }

  Future<void> _fetchFaqs() async {
    setState(() => _loading = true);
    final grouped = await FirestoreService().fetchFaqsByCategory();
    setState(() {
      _faqsByCategory = grouped;
      if (!_faqsByCategory.containsKey(_selectedCategory) &&
          _faqsByCategory.isNotEmpty) {
        _selectedCategory = _faqsByCategory.keys.first;
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use static categories as per the design
    final categories = ['General', 'Account', 'Service', 'Ticket'];
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help Center',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: Colors.grey,
              // Custom indicator for thick, short, rounded blue line
              indicator: UnderlineTabIndicator(
                borderSide:
                    const BorderSide(width: 4.0, color: Color(0xFF2563EB)),
                insets: const EdgeInsets.symmetric(
                    horizontal: 90.0), // makes the line short
              ),
              tabs: const [
                Tab(text: 'FAQ'),
                Tab(text: 'Contact us'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildFaqTab(categories),
                _buildContactTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTab(List<String> categories) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final selected = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: Text(cat,
                      style: TextStyle(
                          color:
                              selected ? Colors.white : const Color(0xFF2563EB),
                          fontWeight: FontWeight.w600)),
                  selected: selected,
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: selected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF2563EB)),
                      borderRadius: BorderRadius.circular(24)),
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _faqsByCategory[_selectedCategory] == null
              ? const Center(child: Text('No FAQs found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _faqsByCategory[_selectedCategory]!.length,
                  itemBuilder: (context, idx) {
                    final faq = _faqsByCategory[_selectedCategory]![idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: ExpansionTile(
                        title: Text(
                          faq['question'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              faq['answer'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildContactTab() {
    // List of contact methods with icon and label
    final contacts = [
      {
        'icon': Icons.headset_mic,
        'label': 'Customer Services',
      },
      {
        'icon': Icons.chat_bubble_outline, // Placeholder for WhatsApp
        'label': 'WhatsApp',
      },
      {
        'icon': Icons
            .camera_alt, // Placeholder for Instagram, use custom icon if available
        'label': 'Instagram',
      },
      {
        'icon': Icons.facebook, // Placeholder, use custom icon if available
        'label': 'Facebook',
      },
      {
        'icon': Icons
            .alternate_email, // Placeholder for Twitter, use custom icon if available
        'label': 'Twitter',
      },
      {
        'icon': Icons.language,
        'label': 'Website',
      },
    ];

    // Custom icon mapping for social icons
    IconData? getSocialIcon(String label) {
      switch (label) {
        case 'WhatsApp':
          return Icons.chat_bubble_outline;
        case 'Instagram':
          return Icons.camera_alt;
        case 'Facebook':
          return Icons.facebook;
        case 'Twitter':
          return Icons.alternate_email;
        case 'Website':
          return Icons.language;
        default:
          return Icons.headset_mic;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      itemCount: contacts.length,
      itemBuilder: (context, idx) {
        final contact = contacts[idx];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListTile(
            leading: Icon(
              getSocialIcon(contact['label'] as String),
              color: const Color(0xFF2563EB),
              size: 32,
            ),
            title: Text(
              contact['label'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            onTap: () {}, // Add action if needed
          ),
        );
      },
    );
  }
}
