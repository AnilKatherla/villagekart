/**
 * **************************************************************
 * @author: Venkat Phanitapu
 * @date: 12 November 2025
 * @project: VillagKart
 * @description: [Widget or ViewModel description]
 * **************************************************************
 */

import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    
    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit to max 10 digits
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    // Insert space after 5 digits
    String formatted = '';
    int selectionIndex = newValue.selection.baseOffset;
    int usedDigits = 0;
    int newCursorPosition = 0;

    for (int i = 0; i < digitsOnly.length; i++) {
      formatted += digitsOnly[i];
      usedDigits++;

      // Track cursor position
      if (usedDigits == selectionIndex) {
        newCursorPosition = formatted.length;
      }

      // Add space after 5 digits
      if (i == 4 && i != digitsOnly.length - 1) {
        formatted += ' ';
        if (usedDigits < selectionIndex) {
          newCursorPosition++; // adjust for space
        }
      }
    }

    // Edge case: cursor at end
    if (selectionIndex >= digitsOnly.length) {
      newCursorPosition = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newCursorPosition.clamp(0, formatted.length),
      ),
    );
  }
}
