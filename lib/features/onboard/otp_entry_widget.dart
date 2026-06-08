import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/onboard/bloc/login_bloc.dart';
import 'package:villag_kart/features/onboard/bloc/login_event.dart';
import 'package:villag_kart/features/onboard/bloc/login_state.dart';

class OtpEntryWidget extends StatefulWidget {
  const OtpEntryWidget({
    super.key,
    required this.phoneNumber,
    required this.onBack,
    required this.onVerify,
    required this.receivedOtp,
  });

  final String phoneNumber;
  final VoidCallback onBack;
  final Function(String otp) onVerify;
  final String receivedOtp;

  @override
  State<OtpEntryWidget> createState() => _OtpEntryWidgetState();
}

class _OtpEntryWidgetState extends State<OtpEntryWidget> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 120;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ================= TIMER =================
  void _startTimer() {
    _remainingSeconds = 120;
    _canResend = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  // ================= OTP =================
  String _getOtp() => _controllers.map((c) => c.text).join();

  bool get _isOtpValid => _getOtp().length == 6;

  // ================= INPUT HANDLING =================
  void _onOtpChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }

      final focusIndex = digits.length >= 6 ? 5 : digits.length;
      _focusNodes[focusIndex].requestFocus();
      return;
    }

    if (digits.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  // ================= VERIFY =================
  void _verifyOtp() {
    final otp = _getOtp();

    if (otp.isEmpty) {
      _showSnack('OTP cannot be empty', Colors.orange);
      return;
    }

    if (otp.length < 6) {
      _showSnack('Please enter complete 6-digit OTP', Colors.orange);
      _focusNodes[otp.length].requestFocus();
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showSnack('Invalid OTP format', Colors.red);
      return;
    }

    widget.onVerify(otp);
  }

  // ================= RESEND =================
  void _resendOtp() {
    _clearOtp();
    _startTimer();
    context.read<LoginBloc>().add(ResendOtpEvent(widget.phoneNumber));
    _showSnack('OTP sent again', Colors.green);
  }

  // ================= CLEAR =================
  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _clearFocusAndOtp() {
    for (final node in _focusNodes) {
      node.unfocus();
    }
    for (final c in _controllers) {
      c.clear();
    }
  }

  void _showSnack(String msg, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: c,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: _focusNodes
          .map(
            (node) => KeyboardActionsItem(
              focusNode: node,
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
          )
          .toList(),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is ValidationFailedState) {
          _clearOtp();
          _showSnack(state.error, Colors.red);
        }
      },
      builder: (context, state) {
        final isVerifying = state is ValidatingOtpState;

        return KeyboardActions(
          disableScroll: true,
          config: _buildConfig(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Enter the OTP',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We have sent a 6 Digits code to',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+91 ${widget.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: isVerifying
                          ? null
                          : () {
                              _clearFocusAndOtp();
                              widget.onBack();
                            },
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                IgnorePointer(
                  ignoring: isVerifying,
                  child: Opacity(
                    opacity: isVerifying ? 0.5 : 1.0,
                    child: _buildOtpBoxes(),
                  ),
                ),
                const SizedBox(height: 24),
                _canResend
                    ? TextButton(
                        onPressed: isVerifying ? null : _resendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : Text(
                        'Resend: ${_remainingSeconds}s',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                const SizedBox(height: 32),
                PrimaryButton(
                  onPressed: _isOtpValid && !isVerifying ? _verifyOtp : null,
                  isLoading: isVerifying,
                  label: 'Verify',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 44,
          child: TextField(
            autofillHints: const [AutofillHints.oneTimeCode],
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(counterText: ''),
            onChanged: (v) => _onOtpChanged(i, v),
            onTap: () {
              _controllers[i].selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controllers[i].text.length,
              );
            },
          ),
        );
      }),
    );
  }
}
