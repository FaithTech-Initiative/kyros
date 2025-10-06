import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  GetStartedScreenState createState() => GetStartedScreenState();
}

class GetStartedScreenState extends State<GetStartedScreen> {
  int _current = 0;
  final List<Map<String, String>> _carouselItems = [
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
    }
  ];

  void _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenGetStarted', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(theme.colorScheme.primary, Colors.black, _current / (_carouselItems.length - 1))!,
              Color.lerp(theme.colorScheme.secondary, Colors.black, _current / (_carouselItems.length - 1))!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        isDarkMode
                            ? 'assets/images/logo_dark.svg'
                            : 'assets/images/logo.svg',
                        height: 180,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 40),
                      CarouselSlider.builder(
                        itemCount: _carouselItems.length,
                        itemBuilder: (context, index, realIndex) {
                          return Column(
                            children: [
                              Text(
                                _carouselItems[index]['title']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _carouselItems[index]['description']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withAlpha(204),
                                ),
                              ),
                            ],
                          );
                        },
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          aspectRatio: 2.0,
                          initialPage: 0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _onGetStarted,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.lato(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
