import 'package:flutter/material.dart';

class LegalTermsScreen extends StatelessWidget {
  const LegalTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Legal, Terms & Conditions",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: const [
          LegalCard(
            title: "Terms of Use",
            shortContent: """ Villag Kart – Terms of Use
Last Updated: 23 October 2025
Welcome to Villag Kart. These Terms of Use govern your access to and use of the Villag Kart mobile application, website, and services (collectively referred to as the Platform....""",
            fullContent: fullTermsText,
          ),

          SizedBox(height: 10),
          LegalCard(
            title: "Privacy Policy",
            shortContent:
                '''At Villag Kart, we respect your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our platform.
1. Information We Collect
We may collect the following information:
• Name and contact details
• Delivery address
• Phone number and email address
• Order history and preferences
• Device and usage information ...
''',
            fullContent: fullPrivacyText,
          ),
          SizedBox(height: 10),
          LegalCard(
            title: "Cancellations and Refunds",
            shortContent: '''Cancellations and Refunds
Villag Kart understands that plans can change. Our cancellation and refund policy is designed to be fair and transparent.
1. Order Cancellation
Customers may cancel an order before it is processed or dispatched for delivery.
2. Scheduled Orders
For scheduled deliveries, cancellations must be made before the order preparation begins.''',
            fullContent: fullCancelText,
          ),
        ],
      ),
    );
  }
}

class LegalCard extends StatefulWidget {
  final String title;
  final String shortContent;
  final String fullContent;

  const LegalCard({
    super.key,
    required this.title,
    required this.shortContent,
    required this.fullContent,
  });

  @override
  State<LegalCard> createState() => _LegalCardState();
}

class _LegalCardState extends State<LegalCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFFFFFF),

      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
              ),
            ),

            const SizedBox(height: 14),

            /// Content (short OR full)
            Text(
              isExpanded ? widget.fullContent : widget.shortContent,
              style: const TextStyle(
                fontSize: 12,
                height: 1.6,

                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 10),

            /// Show More / Less
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? "Read less" : "Read more",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const String fullTermsText = '''
Villag Kart – Terms of Use
Last Updated: 23 October 2025

Welcome to Villag Kart. These Terms of Use govern your access to and use of the Villag Kart mobile application, website, and services (collectively referred to as the “Platform”).

By accessing or using the Platform, you agree to comply with and be bound by these Terms. If you do not agree with any part of these Terms, you should not use the Platform.

1. Eligibility
Users must be at least 18 years old or accessing the platform under the supervision of a parent or legal guardian.

2. Account Registration
To place orders, users may be required to create an account and provide accurate, complete, and updated information.

3. Product Information
We strive to ensure that all product descriptions, pricing, and availability information are accurate. However, errors may occasionally occur, and Villag Kart reserves the right to correct them without prior notice.

4. Orders and Acceptance
All orders placed through the Platform are subject to acceptance and availability. Villag Kart reserves the right to cancel or limit quantities of orders at its discretion.

5. Delivery Services
Delivery times are estimates and may vary due to weather conditions, logistics, or unforeseen circumstances.

6. Prohibited Use
Users must not misuse the platform, attempt unauthorized access, or engage in fraudulent activities.

7. Changes to Terms
Villag Kart may update these Terms from time to time. Continued use of the platform indicates acceptance of the updated terms.
''';

const String fullPrivacyText = '''
Privacy Policy

At Villag Kart, we respect your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our platform.

1. Information We Collect
We may collect the following information:
• Name and contact details
• Delivery address
• Phone number and email address
• Order history and preferences
• Device and usage information

2. How We Use Your Information
Your information is used to:
• Process and deliver your orders
• Improve our services
• Provide customer support
• Send order updates and notifications
• Ensure platform security

3. Data Protection
We implement appropriate security measures to protect your personal information from unauthorized access, misuse, or disclosure.

4. Sharing Information
We do not sell your personal information. However, we may share necessary information with delivery partners and service providers to complete your orders.

5. User Rights
Users may request access, correction, or deletion of their personal information by contacting our support team.

6. Updates to Privacy Policy
This Privacy Policy may be updated periodically to reflect improvements or regulatory changes.
''';

const String fullCancelText = '''
Cancellations and Refunds

Villag Kart understands that plans can change. Our cancellation and refund policy is designed to be fair and transparent.

1. Order Cancellation
Customers may cancel an order before it is processed or dispatched for delivery.

2. Scheduled Orders
For scheduled deliveries, cancellations must be made before the order preparation begins.

3. Refund Eligibility
Refunds may be issued in the following cases:
• Order cancelled by the customer within the allowed time
• Product unavailable after order placement
• Delivery failure due to service issues
• Damaged or incorrect items delivered

4. Refund Process
Approved refunds will be processed to the original payment method or wallet within a reasonable timeframe depending on the payment provider.

5. Non-Refundable Situations
Refunds may not be applicable for:
• Orders cancelled after dispatch
• Incorrect address provided by the customer
• Failed delivery attempts

6. Support
If you face any issue related to cancellations or refunds, you may contact our customer support team through the application.
''';
