import 'package:flutter/services.dart';

class NumberFormatter {
  static String formatNumber(double number) {
    // Format number with commas for thousands
    String formatted = number.toStringAsFixed(0);
    
    // Add commas for thousands
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    formatted = formatted.replaceAllMapped(reg, (Match match) {
      return '${match[1]},';
    });
    
    return formatted;
  }

  static String formatCurrency(double amount) {
    return 'Ksh ${formatNumber(amount)}';
  }

  static double parseFormattedNumber(String formattedNumber) {
    // Remove commas and parse to double
    String cleanNumber = formattedNumber.replaceAll(',', '');
    return double.tryParse(cleanNumber) ?? 0.0;
  }

  static String formatNumberWithDecimals(double number, {int decimals = 2}) {
    // Format number with commas and decimals
    String formatted = number.toStringAsFixed(decimals);
    
    // Split by decimal point
    List<String> parts = formatted.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Add commas to integer part
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    integerPart = integerPart.replaceAllMapped(reg, (Match match) {
      return '${match[1]},';
    });
    
    return decimalPart.isNotEmpty ? '$integerPart.$decimalPart' : integerPart;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters except commas
    String newText = newValue.text.replaceAll(RegExp(r'[^\d,]'), '');
    
    // Remove commas for processing
    String cleanText = newText.replaceAll(',', '');
    
    // If empty, return empty
    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    
    // Parse to number
    double? number = double.tryParse(cleanText);
    if (number == null) {
      return oldValue;
    }
    
    // Format with commas
    String formatted = NumberFormatter.formatNumber(number);
    
    // Calculate cursor position
    int cursorPosition = formatted.length;
    
    // If user is typing at the end, keep cursor at end
    if (newValue.selection.baseOffset >= oldValue.text.length) {
      cursorPosition = formatted.length;
    } else {
      // Try to maintain relative position
      int oldLength = oldValue.text.length;
      int newLength = formatted.length;
      double ratio = newValue.selection.baseOffset / oldLength;
      cursorPosition = (ratio * newLength).round();
    }
    
    // Ensure cursor position is within bounds
    cursorPosition = cursorPosition.clamp(0, formatted.length);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class DecimalInputFormatter extends TextInputFormatter {
  final int maxDecimalPlaces;
  
  DecimalInputFormatter({this.maxDecimalPlaces = 2});
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow digits, commas, and one decimal point
    String newText = newValue.text.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Check for multiple decimal points
    int decimalCount = newText.split('.').length - 1;
    if (decimalCount > 1) {
      return oldValue;
    }
    
    // If there's a decimal point, check decimal places
    if (newText.contains('.')) {
      List<String> parts = newText.split('.');
      if (parts.length > 1 && parts[1].length > maxDecimalPlaces) {
        return oldValue;
      }
    }
    
    // Remove commas for processing
    String cleanText = newText.replaceAll(',', '');
    
    // If empty, return empty
    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    
    // Parse to number
    double? number = double.tryParse(cleanText);
    if (number == null) {
      return oldValue;
    }
    
    // Format with commas
    String formatted = NumberFormatter.formatNumberWithDecimals(number, decimals: maxDecimalPlaces);
    
    // Calculate cursor position
    int cursorPosition = formatted.length;
    
    // If user is typing at the end, keep cursor at end
    if (newValue.selection.baseOffset >= oldValue.text.length) {
      cursorPosition = formatted.length;
    } else {
      // Try to maintain relative position
      int oldLength = oldValue.text.length;
      int newLength = formatted.length;
      double ratio = newValue.selection.baseOffset / oldLength;
      cursorPosition = (ratio * newLength).round();
    }
    
    // Ensure cursor position is within bounds
    cursorPosition = cursorPosition.clamp(0, formatted.length);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
