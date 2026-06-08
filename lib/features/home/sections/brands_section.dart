import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_bloc.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_events.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_state.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_event.dart';
import 'package:villag_kart/features/home/model/brands_model.dart';
import 'package:villag_kart/features/home/sections/section_header.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';

class BrandsSection extends StatefulWidget {
  const BrandsSection({super.key});

  @override
  State<BrandsSection> createState() => _BrandsSectionState();
}

class _BrandsSectionState extends State<BrandsSection> {
  final ScrollController _brandsController = ScrollController();

  double _scrollProgress = 0.0;
  double _totalBrands = 0.0;

  @override
  void initState() {
    super.initState();

    _brandsController.addListener(() {
      if (!_brandsController.hasClients) return;

      final maxScroll = _brandsController.position.maxScrollExtent;

      if (maxScroll == 0) return;

      setState(() {
        _scrollProgress = (_brandsController.offset / maxScroll).clamp(
          0.0,
          1.0,
        );
      });
    });

    _fetchBrands();
  }

  @override
  void dispose() {
    _brandsController.dispose();
    super.dispose();
  }

  void _fetchBrands() async {
    final userId = await LocationService.getUserId();
    final savedLocation = await LocationService.getSavedLocation();

    if (savedLocation == null) return;

    final pincode = savedLocation['pincode'] as String? ?? '';
    final latitude = (savedLocation['latitude'] as num?)?.toDouble() ?? 0.0;
    final longitude = (savedLocation['longitude'] as num?)?.toDouble() ?? 0.0;

    if (pincode.isEmpty || latitude == 0.0 || longitude == 0.0) return;

    if (mounted) {
      context.read<BrandsBloc>().add(
        FetchBrands(
          pincode: pincode,
          latitude: latitude,
          longitude: longitude,
          userId: userId ?? '',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandsBloc, BrandsState>(
      builder: (context, state) {
        if (state is BrandsEmpty) {
          return const SizedBox.shrink();
        }

        List<Brand> brands = [];

        if (state is BrandsLoaded) {
          brands = state.brands;
        } else if (state is BrandsRefreshing) {
          brands = state.brands;
        }

        _totalBrands = brands.length.toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER + PROGRESS BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionHeader(title: 'Our Top Brands'),

                  Container(
                    width: 36,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          end: _totalBrands <= 4
                              ? 1
                              : _scrollProgress.clamp(0.3, 1.0),
                        ),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, value, child) {
                          return Container(
                            width: 36 * value,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (state is BrandsLoading) _buildLoading(),

              if (state is BrandsError) const SizedBox.shrink(),

              if (brands.isNotEmpty) _buildList(brands),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(40),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return SizedBox(
      height: 80,
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildList(List<Brand> brands) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        controller: _brandsController,
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final brand = brands[index];

          return GestureDetector(
            onTap: () {
              context.read<HomeBloc>().add(BrandTapped(brand.name));
            },
            child: SizedBox(
              width: 80,
              child: Column(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: brand.image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => _placeholder(),
                      errorWidget: (_, __, ___) => _placeholder(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    brand.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(Icons.business, size: 20),
    );
  }
}
