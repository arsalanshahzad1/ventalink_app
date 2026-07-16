import 'package:flutter/material.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<List<String>> _sections = [
    [
      "1. Information We Collect",
      "We collect information you provide directly, such as your name, email address, phone number, "
          "and business details when you create an account or storefront. When customers place an "
          "order, we collect the order details and contact information needed to fulfill and track "
          "that order. We also collect basic usage data, such as pages visited and device/browser "
          "information, to help us operate and improve the Service.",
    ],
    [
      "2. How We Use Information",
      "We use collected information to operate your account and storefront, process and display "
          "orders, communicate with you about your account or orders, provide customer support, and "
          "improve the Service. We do not sell your personal information to third parties.",
    ],
    [
      "3. Payment Information",
      "VentaLink does not collect or store card numbers or other sensitive payment credentials. "
          "Payments are completed through the seller's connected payment provider (such as Connecta or "
          "another third-party app), which handles payment data under its own privacy policy.",
    ],
    [
      "4. Sharing of Information",
      "We share order and contact information between a seller and their customer as needed to "
          "complete a transaction. We may also share information with service providers who help us "
          "operate the Service (such as hosting or analytics providers), or when required by law.",
    ],
    [
      "5. Cookies",
      "We use cookies and similar technologies to keep you signed in, remember preferences, and "
          "understand how the Service is used.",
    ],
    [
      "6. Data Security",
      "We use reasonable technical and organizational measures to protect your information. No "
          "method of transmission or storage is completely secure, and we cannot guarantee absolute "
          "security.",
    ],
    [
      "7. Your Rights",
      "You may access, update, or request deletion of your account information at any time by "
          "contacting us or through your account settings, subject to information we are required to "
          "retain for legal or legitimate business purposes.",
    ],
    [
      "8. Children's Privacy",
      "The Service is not directed to children under 13, and we do not knowingly collect personal "
          "information from children under 13.",
    ],
    [
      "9. Changes to This Policy",
      "We may update this Privacy Policy from time to time. Continued use of the Service after "
          "changes are posted constitutes acceptance of the updated policy.",
    ],
    [
      "10. Contact",
      "Questions about this Privacy Policy can be sent to support@ventalink.mx.",
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Privacy Policy", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "This Privacy Policy explains how VentaLink (\"we\", \"us\", \"our\") collects, uses, and "
            "protects information when you use our website, apps, and services (the \"Service\").",
            style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textGrey),
          ),
          const SizedBox(height: 4),
          const Text("Last updated: July 16, 2026", style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
          const SizedBox(height: 20),
          ..._sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section[0], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Text(section[1], style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textGrey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
