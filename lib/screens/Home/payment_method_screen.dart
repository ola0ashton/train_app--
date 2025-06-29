import 'package:flutter/material.dart';
import 'review_summary_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Map<String, dynamic> train;
  final List<Map<String, dynamic>> passengers;
  final int carriage;
  final String seat;
  final String contactName;
  final String contactEmail;
  final String contactPhone;

  const PaymentMethodScreen({
    super.key,
    required this.train,
    required this.passengers,
    required this.carriage,
    required this.seat,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int selectedMethod = 0;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'icon': Icons.account_balance_wallet,
      'label': 'My Wallet',
      'detail': '646.50',
    },
    {
      'icon': Icons.account_balance,
      'label': 'PayPal',
      'detail': '',
    },
    {
      'icon': Icons.account_circle,
      'label': 'Google Pay',
      'detail': '',
    },
    {
      'icon': Icons.apple,
      'label': 'Apple Pay',
      'detail': '',
    },
    {
      'icon': Icons.credit_card,
      'label': 'Visa',
      'detail': '.... .... .... 5567',
    },
  ];

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
        title: const Text('Select Payment Method', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist-Bold')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: paymentMethods.length + 1,
              itemBuilder: (context, idx) {
                if (idx < paymentMethods.length) {
                  final method = paymentMethods[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => selectedMethod = idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFF1F5F9),
                                child: Icon(method['icon'], color: const Color(0xFF2563EB)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(method['label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    if (method['detail'] != null && method['detail'] != '')
                                      Text(method['detail'], style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Radio<int>(
                                value: idx,
                                groupValue: selectedMethod,
                                activeColor: const Color(0xFF2563EB),
                                onChanged: (val) => setState(() => selectedMethod = val!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  // Add New Payment
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Material(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Color(0xFF2563EB)),
                              SizedBox(width: 8),
                              Text('Add New Payment', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewSummaryScreen(
                        train: widget.train,
                        passengers: widget.passengers,
                        carriage: widget.carriage,
                        seat: widget.seat,
                        paymentMethod: paymentMethods[selectedMethod]['label'],
                        contactName: widget.contactName,
                        contactEmail: widget.contactEmail,
                        contactPhone: widget.contactPhone,
                      ),
                    ),
                  );
                },
                child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 