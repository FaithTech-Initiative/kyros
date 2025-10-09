import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;

  const SocialLoginButtons({
    super.key,
    required this.isLoading,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          'assets/images/google_logo.png',
          isLoading ? () {} : onGoogleSignIn,
        ),
        const SizedBox(width: 20),
        if (Theme.of(context).platform == TargetPlatform.iOS)
          _buildSocialButton(
            'assets/images/apple_logo.png',
            isLoading ? () {} : onAppleSignIn,
          ),
      ],
    );
  }

  Widget _buildSocialButton(String imagePath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Image.asset(imagePath, height: 30),
      ),
    );
  }
}
