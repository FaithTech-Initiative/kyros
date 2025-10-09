import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kyros/services/auth_service.dart';
import 'package:kyros/utils/snackbar_helper.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  var _isLogin = true;
  var _isLoading = false;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredName = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || _isLoading) {
      return;
    }

    _formKey.currentState!.save();
    _enteredPassword = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _authService.signInWithEmailAndPassword(
            _enteredEmail, _enteredPassword);
      } else {
        await _authService.createUserWithEmailAndPassword(
            _enteredEmail, _enteredPassword, _enteredName);
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        showSnackBar(context, error.message ?? 'Authentication failed.', isError: true);
      }
    } catch (error) {
      if (mounted) {
        showSnackBar(context, 'An unexpected error occurred.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.signInWithGoogle();
    } catch (error) {
      if (mounted) {
        showSnackBar(context, 'Google Sign-In failed: ${error.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _appleSignIn() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.signInWithApple();
    } catch (error) {
      if (mounted) {
        showSnackBar(context, 'Apple Sign-In failed: ${error.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.signInAnonymously();
    } catch (error) {
      if (mounted) {
        showSnackBar(context, 'Guest sign-in failed: ${error.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setAuthMode(bool isLogin) {
    setState(() {
      _isLogin = isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildTopGradient(context),
          _buildAuthForm(context),
          if (!_isLogin)
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => _setAuthMode(true),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopGradient(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary;
    final gradientColors = [
      baseColor,
      Color.lerp(baseColor, Colors.black, 0.4)!,
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              height: 120,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(height: 24),
            if (_isLogin) const AnimatedSubtitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height:
            MediaQuery.of(context).size.height * (_isLogin ? 0.60 : 0.65),
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ]),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
          child: Form(
            key: _formKey,
            child: _isLogin ? _buildLoginForm() : _buildSignupForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildEmailField(),
        const SizedBox(height: 15),
        _buildPasswordField(),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: _isLoading 
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(height: 20),
        _buildDivider(),
        const SizedBox(height: 20),
        _buildSocialLogins(),
        const SizedBox(height: 20),
        _buildGuestMode(),
        const SizedBox(height: 20),
        _buildToggleAuthMode(),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildNameField(),
        const SizedBox(height: 15),
        _buildEmailField(),
        const SizedBox(height: 15),
        _buildPasswordField(),
        const SizedBox(height: 15),
        _buildConfirmPasswordField(),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account?"),
            TextButton(
              onPressed: _isLoading ? null : () => _setAuthMode(true),
              child: Text(
                'Login',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      validator: (value) {
        if (value == null || value.trim().isEmpty || !value.contains('@')) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
      onSaved: (value) {
        _enteredEmail = value!;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Name',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      enableSuggestions: false,
      validator: (value) {
        if (value == null || value.trim().length < 4) {
          return 'Please enter at least 4 characters.';
        }
        return null;
      },
      onSaved: (value) {
        _enteredName = value!;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.trim().length < 6) {
          return 'Password must be at least 6 characters long.';
        }
        return null;
      },
    );
  }

    Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Passwords do not match.';
        }
        return null;
      },
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('Or login with', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialLogins() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          'assets/images/google_logo.png',
          _isLoading ? () {} : _handleGoogleSignIn,
        ),
        const SizedBox(width: 20),
        if (Theme.of(context).platform == TargetPlatform.iOS)
          _buildSocialButton(
            'assets/images/apple_logo.png',
            _isLoading ? () {} : _appleSignIn,
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

  Widget _buildToggleAuthMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: _isLoading ? null : () => _setAuthMode(false),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildGuestMode() {
    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : _signInAnonymously,
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

class AnimatedSubtitle extends StatefulWidget {
  const AnimatedSubtitle({super.key});

  @override
  State<AnimatedSubtitle> createState() => _AnimatedSubtitleState();
}

class _AnimatedSubtitleState extends State<AnimatedSubtitle> {
  int _currentIndex = 0;
  final List<String> _subtitles = [
    "Capture Insights.",
    "Deepen Your Study.",
    "Build Your Personal Wiki.",
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _subtitles.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        _subtitles[_currentIndex],
        key: ValueKey<int>(_currentIndex),
        style: const TextStyle(fontSize: 18, color: Colors.white70),
      ),
    );
  }
}
