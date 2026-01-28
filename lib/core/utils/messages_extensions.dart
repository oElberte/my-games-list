import 'package:flutter/material.dart';

extension MessagesX on BuildContext {
  void showMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(_buildDefaultSnackBar(message));
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(_buildDefaultSnackBar(message, Colors.red));
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(_buildDefaultSnackBar(message, Colors.green));
  }

  void showWarningMessage(String message) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(_buildDefaultSnackBar(message, Colors.blue));
  }

  void showCustomMessage(String message, Color backgroundColor) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(_buildDefaultSnackBar(message, backgroundColor));
  }

  void hideCurrentMessage() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }

  SnackBar _buildDefaultSnackBar(String message, [Color? backgroundColor]) {
    return SnackBar(content: Text(message), backgroundColor: backgroundColor);
  }
}
