import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/utils/phone_number_formatter.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/onboard/bloc/login_bloc.dart';
import 'package:villag_kart/features/onboard/bloc/login_event.dart';
import 'package:villag_kart/features/onboard/bloc/login_state.dart';

class PhoneEntryWidget extends StatefulWidget {
  const PhoneEntryWidget({
    super.key,
    required this.onSendOtp,
    this.initialPhone,
    this.isEditing = false,
  });

  final void Function(String phone) onSendOtp;
  final String? initialPhone;
  final bool isEditing;

  @override
  State<PhoneEntryWidget> createState() => _PhoneEntryWidgetState();
}

class _PhoneEntryWidgetState extends State<PhoneEntryWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  bool _buttonEnabled = false;
  final String _countryCode = '+91';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(_onPhoneChanged);

    if (widget.initialPhone != null) {
      final digits = widget.initialPhone!.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length > 10 && digits.startsWith('91')) {
        _phoneController.text = digits.substring(2);
      } else {
        _phoneController.text = digits;
      }
    }

    if (widget.isEditing && _phoneController.text.length >= 10) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _buttonEnabled = true);
      });
    }
  }

  void _onPhoneChanged() {
    if (_isUpdating) return;

    final raw = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    String digits = raw;

    if (digits.length > 10 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }
    if (digits != raw) {
      _isUpdating = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _phoneController.value = TextEditingValue(
          text: digits,
          selection: TextSelection.collapsed(offset: digits.length),
        );
        _isUpdating = false;
      });
    }

    setState(() => _buttonEnabled = digits.length >= 10);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _phoneFocus,
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

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<void> _onContinue() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    // Always strip spaces/formatting before sending
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    context.read<LoginBloc>().add(SendOtpEvent(cleanPhone));
    widget.onSendOtp(cleanPhone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isLoading = state is SendingOtpState;

        return KeyboardActions(
          disableScroll: true,
          config: _buildConfig(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Text(
                    widget.isEditing
                        ? 'Edit Phone Number'
                        : 'Enter your Phone number',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.isEditing
                          ? 'We will send a new OTP to verify your identity'
                          : 'We will send a one-time password\nto verify your identity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (widget.isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'Note: You may need to wait before requesting a new OTP for the same number',
                          style: TextStyle(fontSize: 14, color: Colors.orange),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildPhoneField(),
                  const SizedBox(height: 16),
                  _buildBottomButton(isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton(bool isLoading) {
    return PrimaryButton(
      onPressed: (_buttonEnabled && !isLoading) ? _onContinue : null,
      isLoading: isLoading,
      isDisabled: !_buttonEnabled,
      label: 'Send OTP',
    );
  }

  Widget _buildPhoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            _countryCode,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Container(
            width: 1,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                //PhoneNumberFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: 'Phone number',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              validator: _validatePhone,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (_buttonEnabled) {
                  _onContinue();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
