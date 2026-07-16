import 'package:flutter/material.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  static const List<List<String>> _sections = [
    [
      "1. Description of the Service",
      "VentaLink lets sellers create an online storefront, list products, and share a link that "
          "allows customers to place orders and pay through the seller's connected payment provider "
          "(such as Connecta or another third-party payment app). VentaLink does not process or hold "
          "funds itself; payments are handled by the payment provider the seller connects to their store.",
    ],
    [
      "2. Accounts",
      "You must provide accurate information when creating an account and are responsible for "
          "keeping your login credentials secure. You are responsible for all activity that occurs "
          "under your account.",
    ],
    [
      "3. Seller Responsibilities",
      "Sellers are solely responsible for the accuracy of their product listings, pricing, "
          "fulfillment of orders, customer service, and compliance with any laws or regulations "
          "applicable to their business, including tax obligations. VentaLink is not a party to the "
          "sale between a seller and their customer.",
    ],
    [
      "4. Payments",
      "All payments are completed through the seller's connected payment provider. VentaLink is not "
          "responsible for payment failures, chargebacks, refunds, or disputes between a seller and a "
          "customer; these must be resolved directly with the payment provider or between the parties "
          "involved.",
    ],
    [
      "5. Prohibited Use",
      "You may not use the Service to sell illegal goods or services, infringe on intellectual "
          "property rights, distribute malware, or engage in fraudulent or deceptive practices. We may "
          "suspend or terminate accounts that violate these Terms.",
    ],
    [
      "6. Intellectual Property",
      "The VentaLink name, logo, and platform are owned by us. Sellers retain ownership of the "
          "product content and images they upload, and grant us a license to display that content as "
          "part of operating their storefront.",
    ],
    [
      "7. Disclaimers and Limitation of Liability",
      "The Service is provided \"as is\" without warranties of any kind. To the maximum extent "
          "permitted by law, VentaLink is not liable for indirect, incidental, or consequential damages "
          "arising from your use of the Service.",
    ],
    [
      "8. Termination",
      "We may suspend or terminate your access to the Service at any time for violation of these "
          "Terms. You may stop using the Service at any time.",
    ],
    [
      "9. Changes to These Terms",
      "We may update these Terms from time to time. Continued use of the Service after changes are "
          "posted constitutes acceptance of the updated Terms.",
    ],
    [
      "10. Contact",
      "Questions about these Terms can be sent to support@ventalink.mx.",
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Terms and Conditions", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "These Terms and Conditions (\"Terms\") govern your access to and use of VentaLink (the "
            "\"Service\"), operated by VentaLink (\"we\", \"us\", \"our\"). By creating an account, "
            "accessing a storefront, or otherwise using the Service, you agree to be bound by these "
            "Terms. If you do not agree, do not use the Service.",
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
