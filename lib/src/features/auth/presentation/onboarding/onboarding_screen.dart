// lib/src/features/auth/presentation/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  final List<_OnboardData> pages = const [
    _OnboardData(
      image: 'assets/images/onboarding1.png',
      title: 'Your Trusted Guide in Times of Disaster',
      description:
      'Discover peace of mind with real-time guidance and resources designed to keep you safe.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding2.jpg',
      title: 'Empowering Safety, One Step at a Time',
      description:
      'Stay one step ahead in any emergency with tailored solutions that protect you and your loved ones.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding3.png',
      title: 'Preparedness at Your Fingertips',
      description:
      'Take charge of your safety with expert tools and advice that prepare you for the unexpected.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_pageIndex < pages.length - 1) {
      _pageController.animateToPage(
        _pageIndex + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _onSkip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final int total = pages.length;
    final double progress = (_pageIndex + 1) / total;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // PAGEVIEW (image + curved bottom)
            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemBuilder: (context, index) {
                  final item = pages[index];
                  return Column(
                    children: [
                      // Image with curved bottom using ClipPath
                      Expanded(
                        child: ClipPath(
                          clipper: BottomWaveClipper(),
                          child: Image.asset(
                            item.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // CONTENT (title, desc, indicators, progress, buttons)
            Expanded(
              flex: 4,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      pages[_pageIndex].title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pages[_pageIndex].description,
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const Spacer(),

                    // Linear progress + dots
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.shade700),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                            (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: (_pageIndex == i) ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: (_pageIndex == i)
                                ? Colors.green.shade700
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _onNext,
                        child: Text(
                            _pageIndex == pages.length - 1 ? 'Get Started' : 'Continue'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _onSkip,
                          child: const Text('Skip'),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // If you want to allow user to go back to previous page:
                            if (_pageIndex > 0) {
                              _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            }
                          },
                          child: Text(
                            'Back',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String image;
  final String title;
  final String description;
  const _OnboardData({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// Custom clipper to make a nice curved bottom on the image.
/// Ajuste les control points si tu veux une courbe plus/moins prononcée.
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 60);

    // première courbe (vers le centre)
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height,
    );

    // deuxième courbe (vers la droite)
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height,
      size.width,
      size.height - 60,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
