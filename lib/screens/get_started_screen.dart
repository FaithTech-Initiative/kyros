import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  GetStartedScreenState createState() => GetStartedScreenState();
}

class GetStartedScreenState extends State<GetStartedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _animationTimer;

  final List<Map<String, String>> _slideData = [
    {
      "title": "Welcome to Kyros",
      "description":
          "Your personal note and companion for deep and meaningful Bible study."
    },
    {
      "title": "Capture Your Insights",
      "description":
          "Take notes, highlight verses, and organize your thoughts seamlessly."
    },
    {
      "title": "Powerful Study Tools",
      "description":
          "Access commentaries, cross-references, and more to enrich your understanding."
    },
    {
      "title": "Create Your Personal Wiki",
      "description":
          "Build a knowledge base of your spiritual journey and discoveries."
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page?.round() ?? 0;
        });
      }
    });

    _animationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final int nextPage = (_currentPage + 1) % _slideData.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }

  void _onGetStarted() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double slideFraction = _currentPage / (_slideData.length - 1);

    final gradientColors = [
      Color.lerp(primaryColor, darkBackgroundColor, slideFraction)!,
      Color.lerp(secondaryColor, darkBackgroundColor, slideFraction)!,
    ];

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: 180,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slideData.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _slideData[index]['title']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.oswald(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _slideData[index]['description']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.white.withAlpha(217),
                                height: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  _buildPageIndicator(),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _onGetStarted,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 64),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slideData.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withAlpha(128),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
