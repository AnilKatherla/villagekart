import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:villag_kart/core/realtime/consumer_realtime_hub.dart';
import 'package:villag_kart/core/theme/app_typography.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_bloc.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_service.dart';
import 'package:villag_kart/features/profile/view/edit_profile_screen.dart';
import 'package:villag_kart/features/profile/view/manage_address_screen.dart';
import 'package:villag_kart/features/profile/view/order_history_screen.dart';
import 'package:villag_kart/features/profile/view/refunds_screen.dart';
import 'package:villag_kart/features/profile/view/wishlist_screen.dart';
import 'package:villag_kart/features/profile/view/faq_screen.dart';
import 'package:villag_kart/features/profile/view/send_feedback_screen.dart';
import 'package:villag_kart/features/profile/view/legal_terms_screen.dart';
import 'package:villag_kart/features/profile/view/about_us_screen.dart';
import 'package:villag_kart/features/profile/widgets/custom_list_tile.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_state.dart';
import 'package:villag_kart/features/inviteFriends/invite.dart';
import 'package:villag_kart/features/profile/bloc/edit_profile/edit_profile_bloc.dart';
import 'package:villag_kart/features/profile/bloc/edit_profile/edit_profile_event.dart';
import 'package:villag_kart/features/profile/bloc/edit_profile/edit_profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedProfileImage();
  }

  Future<void> _loadSavedProfileImage() async {
    final path = await SharedPrefs.getProfileImagePath();
    if (path != null && mounted) {
      setState(() {
        _imageFile = File(path);
      });
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4.15, width: 47, color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                context.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () {
                context.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      // Get permanent app directory
      final directory = await getApplicationDocumentsDirectory();

      // Create new path
      final newPath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Copy image from cache to permanent storage
      final savedImage = await File(pickedFile.path).copy(newPath);

      setState(() {
        _imageFile = savedImage;
      });

      // Persist permanent path
      await SharedPrefs.saveProfileImagePath(savedImage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc()..add(FetchUserProfile()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            if (state is UserProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserProfileBloc>().add(FetchUserProfile());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is UserProfileLoaded) {
              final user = state.userProfile;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Profile Header Section =====
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // EDIT button aligned to top-right
                            Align(
                              alignment: Alignment.topRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfileScreen(),
                                    ),
                                  );
                                  if (updated == true) {
                                    context.read<UserProfileBloc>().add(
                                      FetchUserProfile(),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'EDIT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Centered avatar + name + phone
                            Center(
                              child: Column(
                                children: [
                                  // Profile Avatar with edit icon
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage: _imageFile != null
                                              ? FileImage(_imageFile!)
                                              : (user.avatar != null &&
                                                        user
                                                            .avatar!
                                                            .isNotEmpty &&
                                                        user.avatar !=
                                                            'https://example.com/profile.jpg'
                                                    ? NetworkImage(user.avatar!)
                                                    : null),
                                          child:
                                              (_imageFile == null &&
                                                  (user.avatar == null ||
                                                      user.avatar!.isEmpty ||
                                                      user.avatar ==
                                                          'https://example.com/profile.jpg'))
                                              ? Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    'assets/images/villagekart_logo.svg',
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      // Edit icon overlay
                                      Positioned(
                                        right: 2,
                                        bottom: 12,
                                        child: GestureDetector(
                                          onTap: _showImagePickerSheet,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: const Color(0xFFFFFFFF),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Name
                                  Text(
                                    user.name ?? 'User',
                                    style: const TextStyle(
                                      color: Color(0XFF000000),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // Phone
                                  Text(
                                    user.phone ?? 'N/A',
                                    style: const TextStyle(
                                      color: Color(0XFF555555),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 19),

                            IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Total Orders
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.totalOrdersCount.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Total Orders',
                                          style: TextStyle(
                                            color: Color(0XFF333333),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Vertical divider
                                  const VerticalDivider(
                                    thickness: 1,
                                    color: Color(0XFFEFEFEF),
                                  ),

                                  // Wishlist
                                  Expanded(
                                    child:
                                        BlocBuilder<
                                          WishlistBloc,
                                          WishlistState
                                        >(
                                          builder: (context, wishlistState) {
                                            String count = user
                                                .totalWishlistCount
                                                .toString();
                                            if (wishlistState
                                                is WishlistLoaded) {
                                              count = wishlistState
                                                  .wishlistItems
                                                  .length
                                                  .toString();
                                            } else if (wishlistState
                                                is WishlistRefreshing) {
                                              count = wishlistState
                                                  .wishlistItems
                                                  .length
                                                  .toString();
                                            } else if (wishlistState
                                                is WishlistLoadingMore) {
                                              count = wishlistState
                                                  .wishlistItems
                                                  .length
                                                  .toString();
                                            } else if (wishlistState
                                                is WishlistEmpty) {
                                              count = '0';
                                            }

                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  count,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  'Wishlist',
                                                  style: TextStyle(
                                                    color: Color(0XFF333333),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      _buildDivider(),
                      const SizedBox(height: 8),

                      // ===== My Account Section =====
                      _buildSectionTitle(
                        'My account',
                        'Orders, offers, settings, payments ...',
                      ),
                      const SizedBox(height: 8),
                      _buildCardContainer([
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset('assets/icons/my orders.svg'),
                          title: 'My Orders',
                          onTap: () {
                            context.pushNamed('orderHistory');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/location.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Manage Address',
                          onTap: () {
                            context.pushNamed('manageAddress');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/refunds.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Refunds',
                          onTap: () {
                            context.pushNamed('refunds');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/wishlist.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Wishlist',
                          onTap: () {
                            context.pushNamed('wishlist');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/notifications.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Notification Settings',
                          onTap: () {
                            context.pushNamed('notificationsettings');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/invite friends.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Invite Friends',
                          onTap: () {
                            context.pushNamed(
                              'inviteFriends',
                              extra: {
                                'referralCode': user.inviteRefCode ?? '',
                                'shareMessage':
                                    user.shareMessage ??
                                    'Join me using my referral code:',
                              },
                            );
                          },
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // ===== Support & General Info Section =====
                      _buildSectionTitle(
                        'Support & General info',
                        'Local Store, Help frequently asked questions..',
                      ),
                      const SizedBox(height: 8),
                      _buildCardContainer([
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/support.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Support',
                          onTap: () {
                            context.pushNamed(
                              'chatsupport',
                              extra: _imageFile?.path,
                            );
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/FAQ.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Frequently Asked Questions',
                          onTap: () {
                            context.push('/faq');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/Suggestion svg.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'I have a suggestion',
                          onTap: () {
                            context.pushNamed('suggestions');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/feedback svg.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Send Feedback',
                          onTap: () {
                            context.pushNamed('sendFeedback');
                          },
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // ===== Terms & Conditions Section =====
                      _buildSectionTitle(
                        'Terms & Conditions',
                        'Privacy Policies, About us..',
                      ),
                      const SizedBox(height: 8),
                      _buildCardContainer([
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/terms svg.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Legal, Terms & Conditions',
                          onTap: () {
                            context.pushNamed('legal');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/about us avg.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'About us',
                          onTap: () {
                            context.pushNamed('aboutUs');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuTile(
                          context,
                          icon: SvgPicture.asset(
                            'assets/icons/lgout svg.svg',
                            width: 24,
                            height: 24,
                          ),
                          title: 'Logout',
                          onTap: () async {
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: EdgeInsets.zero,
                                content: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 20,
                                        color: const Color(
                                          0xFF707070,
                                        ).withOpacity(0.15),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 🔥 FIXED OVAL HEADER
                                      SizedBox(
                                        height: 90,
                                        width: double.infinity,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            // 🔶 OVAL (bottom half only)
                                            Positioned(
                                              top: -60,
                                              left: -30,
                                              right: -30,
                                              child: ClipRect(
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  heightFactor: 0.8,
                                                  child: Container(
                                                    height: 180,
                                                    decoration: ShapeDecoration(
                                                      color: const Color(
                                                        0xFFFF8800,
                                                      ).withOpacity(0.20),
                                                      shape: const OvalBorder(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // ✅ ICON (properly centered in visible area)
                                            const Positioned(
                                              bottom: 25, // adjust as needed
                                              child: Icon(
                                                Icons.check_circle_outline,
                                                size: 50,
                                                color: Color(0xFFFF8800),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      const Text(
                                        'Logout?',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Segoe UI',
                                          color: Color(0xFF000000),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'Are you sure want to logout from this device?',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Segoe UI',
                                            color: Color(0xFF000000),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Container(
                                              color: const Color(0xFF2C9E02),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              child: const Text(
                                                'Logout',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ),
                            );

                            if (shouldLogout == true && context.mounted) {
                              await ConsumerRealtimeHub.instance.disconnect();
                              await SharedPrefs.clearAll();
                              if (context.mounted) {
                                context.go('/splash');
                              }
                            }
                          },
                        ),
                      ]),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(width: 22, height: 22, child: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFCCCCCC),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(height: 1, color: const Color(0xFFF0F0F0)),
    );
  }

  Widget _buildDivider() {
    return Container(height: 2, color: const Color(0xFFF5F5F5));
  }

  Widget _buildInfoCard(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
