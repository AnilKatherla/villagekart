import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// SCREEN 1: Something Went Wrong
// ============================================================

class SomethingWentWrongScreen extends StatelessWidget {
  final VoidCallback? onTryAgain;
  final String? message;

  const SomethingWentWrongScreen({super.key, this.onTryAgain, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Illustration
              SvgPicture.asset('assets/images/feelsad.svg', height: 140),
              const SizedBox(height: 36),

              /// Title
              const Text(
                'someting went\nwrong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFEF5A06),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              /// Subtitle
              Text(
                message ?? 'Unable to proceed at the moment',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),

              /// Contact Support Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed('staticSupport');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C9E19),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Contact Support',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Try Again
              GestureDetector(
                onTap: onTryAgain ?? () => Navigator.of(context).pop(),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF2C9E19),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SCREEN 2: Support Screen
// ============================================================

class StaticSupportScreen extends StatelessWidget {
  // Replace with real values or pass via constructor
  final String supportPhone;
  final String supportEmail;

  const StaticSupportScreen({
    super.key,
    this.supportPhone = '+91 987654321',
    this.supportEmail = 'villagkartsupportteam@gmail.com',
  });

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:${supportPhone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:$supportEmail');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
        ),
        title: const Text(
          'Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            /// Description
            const Text(
              'You can get in touch with us through below platforms . Our Team will reach out to you as soon as it would be possible',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            /// Section label
            const Text(
              'Customer Support',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            /// Phone card
            _buildContactCard(
              label: 'Contact Number',
              value: supportPhone,
              icon: Icons.phone_outlined,
              onTap: _launchPhone,
            ),

            const SizedBox(height: 12),

            /// Email card
            _buildContactCard(
              label: 'Email Address',
              value: supportEmail,
              icon: Icons.mail_outline,
              onTap: _launchEmail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 26, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
