// ignore_for_file: unused_element

/// **************************************************************
/// @author: ragul
/// @date: 12 November 2025
/// @project: VillagKart
/// @description: [Widget or ViewModel description]
/// **************************************************************
library;

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:villag_kart/core/utils/app_strings.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({
    super.key,
    required this.referralCode,
    this.shareMessage = 'Join me using my referral code:',
  });
  final String referralCode;
  final String shareMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          AppStrings.appBarTitle,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
          child: Column(
            children: [
              //const SizedBox(height: 20),

              // Illustration
              Container(
                width: double.infinity,
                //height: 280,
                decoration: const BoxDecoration(
                  //shape: BoxShape.rectangle,
                  color: Color(0xFFF9CBC2),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/Groupdissuss.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Description text
              const Text(
                AppStrings.descriptionLine1,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                AppStrings.descriptionLine2,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Referral code box with dots
              DottedBorder(
                color: Colors.grey.shade400,
                dashPattern: [6, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),

                child: Container(
                  padding: const EdgeInsets.all(20),
                  // decoration: BoxDecoration(
                  //   // border: Border.all(color: Colors.grey.shade300, width: 2,style: BorderStyle.solid),
                  //   // borderRadius: BorderRadius.circular(12),
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.referralCodeLabel,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          // Referral code displayed with dots
                          Text(
                            _formatCodeWithDots(referralCode),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 2,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ],
                      ),

                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: referralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(AppStrings.copiedMessage),
                              backgroundColor: Color(0xFF4CAF50),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Column(
                          children: [
                            Text(
                              AppStrings.copyText,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              AppStrings.codeText,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Refer button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: PrimaryButton( 
                  onPressed: () {
                    _handleShare(context);
                  },
                  label: AppStrings.referButtonText,
                  ),   
              ),

              const SizedBox(height: 20),

              const Row(
                children: [
                  Icon(Icons.info_outline_rounded),
                  SizedBox(width: 8),
                  Text(
                    'How it works',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: circles + line
                  Column(
                    children: [
                      _stepCircle('1'),
                      _verticalLine(),
                      _stepCircle('2'),
                      _verticalLine(),
                      _stepCircle('3'),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Right side: text
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _stepText(
                        'Invite your friends and family by\nSharing your referral code',
                      ),
                      SizedBox(height: 19),
                      _stepText(
                        'Share the invitation link on\nsocial platforms',
                      ),
                      SizedBox(height: 19),
                      _stepText(
                        'Rewards will get after successful\nregister with referral code',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Format code with dots (e.g., "ABC12345" becomes "ABC•••••45")
  String _formatCodeWithDots(String code) {
    if (code.length <= 3) return code;

    final start = code.substring(0, 3);
    final end = code.substring(code.length - 2);
    final dotsCount = code.length - 5;
    final dots = '•' * dotsCount;

    return '$start$dots$end';
  }

  Widget _buildStep(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare(BuildContext context) {
    const String playStoreLink =
        'https://play.google.com/store/apps/details?id=com.villagkartview.customer';

    final String fullMessage =
        '$shareMessage $referralCode\n\nDownload the app:\n$playStoreLink';

    Share.share(fullMessage, subject: 'Invite to join VillagKart');
  }

  Widget _stepCircle(String number) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 6,
            spreadRadius: 0,
            color: Color(0x29000000),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Color(0xFF00891D),
            fontWeight: FontWeight.w700,

            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _verticalLine() {
    return const SizedBox(
      height: 25,
      child: DottedLine(
        direction: Axis.vertical,
        lineThickness: 1,
        dashLength: 3,
        dashGapLength: 3,
        dashColor: Color(0xFF00891D),
      ),
    );
  }
}

class _stepText extends StatelessWidget {
  final String text;
  const _stepText(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,

          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }
}
