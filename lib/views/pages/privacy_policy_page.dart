import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFBBDEFB),
                Color(0xFF0A1F36),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF0F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                "Introduction",
                "Welcome to our POS System. We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data.",
              ),
              _buildSection(
                "Information We Collect",
                "• Personal information (name, email, contact details)\n"
                    "• Business information (branch details, transaction data)\n"
                    "• Device information (IP address, device type)\n"
                    "• Usage data (app interactions, preferences)",
              ),
              _buildSection(
                "How We Use Your Information",
                "• To provide and maintain our services\n"
                    "• To process transactions and manage your account\n"
                    "• To improve our services and user experience\n"
                    "• To communicate with you about updates and support",
              ),
              _buildSection(
                "Data Security",
                "We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.",
              ),
              _buildSection(
                "Your Rights",
                "You have the right to:\n"
                    "• Access your personal data\n"
                    "• Correct inaccurate data\n"
                    "• Request deletion of your data\n"
                    "• Opt-out of marketing communications",
              ),
              _buildSection(
                "Contact Us",
                "If you have any questions about this Privacy Policy, please contact us at:\n"
                    "Email: support@possystem.com\n"
                    "Phone: +1 (555) 123-4567",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1F36),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
