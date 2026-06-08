/// **************************************************************
/// @author: Venkat Phanitapu
/// @date: 12 November 2025
/// @project: VillagKart
/// @description: [Widget or ViewModel description]
/// **************************************************************
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:villag_kart/features/address/address_card.dart';
import 'package:villag_kart/features/address/address_model.dart';
import 'package:villag_kart/features/location/widgets/current_location_card.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key, required this.address});
  final String address;

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final FocusNode _searchFocus = FocusNode();
  List<AddressModel> savedAddresses = [
  //   AddressModel(
  //     label: 'Home',
  //     address: 'Vinayakrao Nagar, AB Towers, Street No 2, Hyderabad 500081',
  //     distanceKm: 0.5,
  //   ),
  //   AddressModel(
  //     label: 'Office',
  //     address:
  //         'B2-415, 1-5, Rd Number 4, Green Valley, Banjara Hills, Hyderabad 500034',
  //     distanceKm: 2.1,
  //   ),
  //   AddressModel(
  //     label: 'Others',
  //     address: 'No-2, LG-83, Road Number 2, KPHB Colony, Hyderabad 500085',
  //     distanceKm: 2.6,
  //   ),
   ];

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _searchFocus,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Delivery location'),
        centerTitle: false,
      ),
      body: KeyboardActions(
        config: _buildConfig(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _searchBar(),
              const SizedBox(height: 12),
              CurrentLocationCard(
                location: widget.address,
                onChange: () {
                  debugPrint('clicked on change');
                  context.pushNamed('home', extra: widget.address);
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: savedAddresses.length,
                  itemBuilder: (context, index) {
                    final addr = savedAddresses[index];
                    return InkWell(
                      onTap: () {
                        context.goNamed('home', extra: addr);
                      },
                      child: AddressCard(
                        address: addr,
                        onEdit: () {

                        },
                        onDelete: () {

                        },
                        onShare: () {
                          
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.green),
                label: const Text(
                  'Add new address',
                  style: TextStyle(color: Colors.green),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      focusNode: _searchFocus,
      decoration: InputDecoration(
        hintText: 'Search for area, street name...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
