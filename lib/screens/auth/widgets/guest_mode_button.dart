import 'package:flutter/material.dart';

class GuestModeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSignInAnonymously;

  const GuestModeButton({
    super.key,
    required this.isLoading,
    required this.onSignInAnonymously,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: isLoading ? null : onSignInAnonymously,
        child: Text(
          'Continue as Guest',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
