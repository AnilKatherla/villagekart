import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_bloc.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_event.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_state.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FAQScreen> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
        ),
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: BlocBuilder<DeliveryFaqBloc, DeliveryFaqState>(
        builder: (context, state) {
          if (state is DeliveryFaqLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeliveryFaqError) {
            return Center(child: Text(state.message));
          }

          if (state is DeliveryFaqLoaded) {
            final faqs = state.faqs;

            if (faqs.isEmpty) {
              return const Center(child: Text('No FAQ found'));
            }

            return ListView.builder(
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                final bool isExpanded = expandedIndex == index;

                return Column(
                  children: [
                    ExpansionTile(
                      key: Key(index.toString()),
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (value) {
                        setState(() {
                          expandedIndex = value ? index : null;
                        });
                      },
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        faq.question,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: isExpanded
                            ? const Color(0xFFEF5A06)
                            : Colors.black,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            faq.answer,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 0,
                      thickness: 0.3,
                      color: isExpanded
                          ? const Color(0xFFEF5A06)
                          : Colors.grey.shade300,
                    ),
                  ],
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
