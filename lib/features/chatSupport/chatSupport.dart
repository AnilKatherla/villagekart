/**
 * **************************************************************
 * @author: ragul
 * @date: 12 November 2025
 * @project: VillagKart
 * @description: [Widget or ViewModel description]
 * **************************************************************
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/chatSupport/chat.dart';

class LagroceSupportScreen extends StatefulWidget {
  const LagroceSupportScreen({Key? key}) : super(key: key);

  @override
  State<LagroceSupportScreen> createState() => _LagroceSupportScreenState();
}

class _LagroceSupportScreenState extends State<LagroceSupportScreen> {
  late List<bool> expandedStates;

  @override
  void initState() {
    super.initState();
    expandedStates = [false, false, true];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          onPressed: () => context.pop(context),
        ),
        title: const Text(
          'Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ExpansionTile(
            title: const Text(
              'I have a payment or refund related query?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            trailing: Icon(
              expandedStates[0] ? Icons.expand_less : Icons.expand_more,
              color: Colors.black54,
            ),
            onExpansionChanged: (value) {
              setState(() {
                expandedStates[0] = value;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  'Content for payment or refund query',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1, color: Colors.grey[300]),
          ExpansionTile(
            title: const Text(
              'I have a promotion code or lagroce cash\nRelated issues',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              maxLines: 2,
            ),
            trailing: Icon(
              expandedStates[1] ? Icons.expand_less : Icons.expand_more,
              color: Colors.black54,
            ),
            onExpansionChanged: (value) {
              setState(() {
                expandedStates[1] = value;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  'Content for promotion code or lagroce cash issues',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          Divider(height: 1, color: Colors.grey[300]),
          ExpansionTile(
            initiallyExpanded: true,
            title: const Text(
              'Any Other query',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            trailing: Icon(
              expandedStates[2] ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFFE97C3C),
            ),
            onExpansionChanged: (value) {
              setState(() {
                expandedStates[2] = value;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // start alignment
                  children: [
                    const Text(
                      'Please let\'s know how we can help',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft, // force start
                      child: OutlinedButton(
                        onPressed: () async {
                          final path = await SharedPrefs.getProfileImagePath();
                          if (context.mounted) {
                            context.pushNamed(
                              'chatscreen',
                              extra: path, // ✅ pass profile image path
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFE97C3C),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18, // reduced
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Chat',
                          style: TextStyle(
                            color: Color(0xFFE97C3C),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}
