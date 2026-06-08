import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import '../bloc/edit_profile/edit_profile_bloc.dart';
import '../bloc/edit_profile/edit_profile_event.dart';
import '../bloc/edit_profile/edit_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final _formKey = GlobalKey<FormState>();
  late UserProfileBloc _profileBloc;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _profileBloc = context.read<UserProfileBloc>();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    
    _profileBloc.add(FetchUserProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nameFocus,
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
        KeyboardActionsItem(
          focusNode: _emailFocus,
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

  void _saveDetails() {
    if (_formKey.currentState!.validate()) {
      _profileBloc.add(
        UpdateUserProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Edit profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(context),
        ),
      ),
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          // ✅ Fill textfields when data arrives
          if (state is UserProfileLoaded) {
            _nameController.text = state.userProfile.name;
            _emailController.text = state.userProfile.email;
            _phoneController.text = state.userProfile.phone;
          }

          if (state is UserProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) context.pop(true);
            });
          } else if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            final isUpdating = state is UserProfileUpdating;

            return KeyboardActions(
              config: _buildConfig(context),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Name",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      enabled: !isUpdating,
                      decoration: _inputDecoration("Enter your name"),
                      validator: (value) {

                        final trimmed = value?.trim()?? '';

                        if (trimmed == null ||trimmed.isEmpty) {
                          return 'Name cannot be empty';
                        }
                        if (trimmed.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        if(trimmed.length > 50){
                          return 'Name cannot exceed 50 characters';
                        }

                        final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
                        if(!nameRegex.hasMatch(trimmed)){
                          return 'Name should contain only letters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Email ID",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      enabled: !isUpdating,
                      decoration: _inputDecoration("Enter your email"),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';

                        if (trimmed == null || trimmed.isEmpty) {
                          return 'Email cannot be empty';
                        }

                        if(trimmed.length > 100){
                          return 'Email too long';
                        }
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(trimmed)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Phone number",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      enabled: false,
                      decoration: _inputDecoration("Phone number").copyWith(
                        hintText: "Phone number cannot be changed",
                        fillColor: Colors.grey.shade100,
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your phone number is tied to your account and cannot be changed",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 40),

                    
                    PrimaryButton(
  label: "Save details",
  isLoading: isUpdating,
  onPressed: isUpdating ? null : _saveDetails,
)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.green),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
 
