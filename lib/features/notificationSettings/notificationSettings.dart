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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:villag_kart/features/notificationSettings/notificationTile.dart';



class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool orderAndSupportEnabled = true;
  bool offersEnabled = false;
  bool promotionsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      orderAndSupportEnabled = prefs.getBool('order_support') ?? true;
      offersEnabled = prefs.getBool('offers') ?? false;
      promotionsEnabled = prefs.getBool('promotions') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(context),
        ),
        title: const Text(
          'Notification settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          NotificationTile(
            title: 'Order and support',
            description:
                'Receive notifications related to your order status\nPayments and support communications',
            isEnabled: orderAndSupportEnabled,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('order_support', value);

              setState(() {
                orderAndSupportEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),
          NotificationTile(
            title: 'Offers',
            description:
                'Receive notifications related to new offers\nWhich will save you extra on your orders.',
            isEnabled: offersEnabled,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('offers', value);

              setState(() {
                offersEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),
          NotificationTile(
            title: 'Promotions and new launches',
            description:
                'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.',
            isEnabled: promotionsEnabled,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('promotions', value);

              setState(() {
                promotionsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
