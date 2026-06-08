import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/features/profile/bloc/aboutus_page/aboutus_bloc.dart';
import 'package:villag_kart/features/profile/bloc/aboutus_page/aboutus_event.dart';
import 'package:villag_kart/features/profile/bloc/aboutus_page/aboutus_state.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AboutusBloc()..add(LoadAboutusEvent()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFEF5A06),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(context),
          ),
          title: const Text(
            'About Us',
            style: TextStyle(
              fontFamily: 'Seoge UI',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        body: BlocBuilder<AboutusBloc, AboutusState>(
          builder: (context, state) {
            if (state is Aboutusloading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AboutusError) {
              return Center(child: Text(state.message));
            }
            if (state is AboutusLoaded) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          height: 503,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFEF5A06),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 3),
                                blurRadius: 6,
                                spreadRadius: 0,
                                color: const Color(
                                  0xFFEBEBEB,
                                ).withOpacity(0.16),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 149,
                                width: 208,
                                child: SvgPicture.asset(
                                  'assets/images/Aboutlogo.svg',
                                ),
                              ),
                              const Text(
                                'About us',
                                style: TextStyle(
                                  fontFamily: 'Seoge UI',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),

                              Text(
                                state.about.caption,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Seoge UI',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 300,
                          // left: 67,
                          child: SizedBox(
                            height: 237,
                            width: 227,
                            child: SvgPicture.asset(state.about.image),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 52),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Text(
                            state.about.text1,
                            style: const TextStyle(
                              fontFamily: 'Seoge UI',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF000000),
                            ),
                          ),

                          const SizedBox(height: 30),
                          Text(
                            state.about.text2,
                            style: const TextStyle(
                              fontFamily: 'Seoge UI',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF000000),
                            ),
                          ),

                          const SizedBox(height: 30),
                          Text(
                            state.about.text3,
                            style: const TextStyle(
                              fontFamily: 'Seoge UI',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF000000),
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Divider(
                            height: 0,
                            thickness: 1,
                            color: Color(0xFFDDDDDD),
                          ),

                          const SizedBox(height: 30),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'The better way to get \n Things done',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF9F9F9F),
                                  ),
                                ),
                                const SizedBox(height: 7),

                                const Text(
                                  'Just VillagKart it!',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEF5A06),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Villagkart India Private Limited',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  state.about.address,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 55),
                          const Divider(
                            height: 0,
                            thickness: 1,
                            color: Color(0xFFDDDDDD),
                          ),

                          SizedBox(
                            height: 109,
                            width: 152,
                            child: SvgPicture.asset(
                              'assets/images/villagekart_logo.svg',
                            ),
                          ),

                          const Text(
                            'Terms and conditions | Privacy Polocy',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF000000),
                            ),
                          ),

                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/twitter.svg',
                                color: Color(0xFF000000),
                              ),
                              SizedBox(width: 12),
                              SvgPicture.asset(
                                'assets/images/linkedin.svg',
                                color: Color(0xFF000000),
                              ),
                              SizedBox(width: 12),
                              SvgPicture.asset(
                                'assets/images/Icon metro-facebook.svg',
                                color: Color(0xFF000000),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
