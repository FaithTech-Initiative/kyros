import 'package:flutter/material.dart';

class AuthModeToggle extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final void Function(bool) setAuthMode;

  const AuthModeToggle({
    super.key,
    required this.isLogin,
    required this.isLoading,
    required this.setAuthMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(isLogin ? "Don't have an account?" : "Already have an account?"),
        TextButton(
          onPressed: isLoading ? null : () => setAuthMode(!isLogin),
          child: Text(
            isLogin ? 'Sign Up' : 'Login',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
