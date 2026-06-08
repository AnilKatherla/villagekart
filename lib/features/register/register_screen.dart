/// **************************************************************
/// @author: Venkat Phanitapu
/// @date: 12 November 2025
/// @project: VillagKart
/// @description: [Widget or ViewModel description]
/// **************************************************************
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:villag_kart/core/navigation/route_names.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/profile/view/legal_terms_screen.dart';
import 'package:villag_kart/features/register/bloc/register_bloc.dart';
import 'package:villag_kart/features/register/bloc/register_event.dart';
import 'package:villag_kart/features/register/bloc/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _referralFocus = FocusNode();

  bool _autoValidate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _referralFocus.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      actions: [
        KeyboardActionsItem(
          focusNode: _nameFocus,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ],
        ),
        KeyboardActionsItem(
          focusNode: _emailFocus,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ],
        ),
        KeyboardActionsItem(
          focusNode: _referralFocus,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      //  LISTENER: Handle side effects
      listener: (context, state) async {
        if (state is RegisterSuccessState) {
          //  Success - Navigate to location screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );

          // TODO: Save token to secure storage here
          // await SecureStorage.saveToken(state.token);
          // await NavigationHelper.handlePostAuthFlow(context);
          if (context.mounted) {
            context.pushNamed('serviceability');
          }
        }

        if (state is RegisterErrorState) {
          // Error - Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },

      // BUILDER: Build UI based on state
      builder: (context, state) {
        final isLoading = state is RegisteringState;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: KeyboardActions(
              config: _buildConfig(context),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  children: [
                    SizedBox(height: 30.h),
                    Text(
                      'Hey, Welcome!',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Register with your personal details',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    /// Form Fields
                    AutofillGroup(
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autoValidate
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Your Name', isRequired: true),
                            _buildTextField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              hintText: 'Ex. David Smith',
                              keyboardType: TextInputType.name,
                              autofillHints: [AutofillHints.name],
                              enabled: !isLoading, // ✅ Disable during loading
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Please enter your name'
                                  : null,
                            ),
                            SizedBox(height: 16.h),
                            _buildLabel('Email ID'),
                            _buildTextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              hintText: 'Ex. James@gmail.com',
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: [AutofillHints.email],
                              enabled: !isLoading,
                              validator: (v) {
                                if (v != null && v.isNotEmpty) {
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(v)) {
                                    return 'Enter valid email';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            _buildLabel('Referral Code'),
                            _buildTextField(
                              controller: _referralController,
                              focusNode: _referralFocus,
                              hintText: 'Ex. AB12345',
                              keyboardType: TextInputType.text,
                              enabled: !isLoading,
                            ),
                            SizedBox(height: 40.h),

                            /// Continue Button
                            PrimaryButton(
                              isLoading: isLoading,
                              isDisabled: isLoading,
                              onPressed: _onContinue,
                              label: 'Continue',
                              loader: SizedBox(
                                height: 22.h,
                                width: 22.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'By Continuing, You accept our',
                                    style: TextStyle(
                                      color: AppColors.black,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      context.pushNamed('legal');
                                    },
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 12.sp,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Terms and Conditions',
                                            style: TextStyle(
                                              color: AppColors.orange,
                                              fontSize: 12.sp,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          const TextSpan(text: ' & '),
                                          TextSpan(
                                            text: 'Privacy Policies',
                                            style: TextStyle(
                                              color: AppColors.orange,
                                              fontSize: 12.sp,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.black,
          fontWeight: FontWeight.w400,
          fontFamily: 'Segoe UI', // Ensure consistent font
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            TextSpan(
              text: ' (Optional)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      enabled: enabled, // ✅ Disable during loading
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: AppColors.black.withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      // ✅ Hide keyboard
      FocusScope.of(context).unfocus();

      // ✅ Dispatch registration event
      context.read<RegisterBloc>().add(
        RegisterUserEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          referralCode: _referralController.text.trim().isEmpty
              ? null
              : _referralController.text.trim(),
        ),
      );
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }
}
