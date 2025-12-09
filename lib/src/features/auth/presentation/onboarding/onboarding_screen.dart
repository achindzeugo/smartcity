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
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;

    final bool isSmallHeight = size.height < 700;      // petits téléphones
    final bool isVerySmallHeight = size.height < 600;  // très petits / vieux téléphones

    final int total = pages.length;
    final double progress = (_pageIndex + 1) / total;

    // padding et tailles qui s’adaptent à la largeur / hauteur
    final double horizontalPadding = size.width * 0.06; // ~24 sur 400px
    final double verticalPadding = size.height * 0.02;  // ~16 sur 800px

    final double titleFontSize = isSmallHeight ? 20 : 22;
    final double descFontSize = isSmallHeight ? 14 : 15;
    final double buttonFontSize = isSmallHeight ? 14 : 16;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxH = constraints.maxHeight;
            final bool compact = maxH < 650;

            return Column(
              children: [
                // --- Partie image ---
                Expanded(
                  flex: compact ? 5 : 6,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _pageIndex = i),
                    itemBuilder: (context, index) {
                      final item = pages[index];
                      return Column(
                        children: [
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

                // --- Partie contenu (titre, texte, boutons) ---
                Expanded(
                  flex: compact ? 5 : 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: SingleChildScrollView(
                      // 👆 important pour éviter les overflow sur petits écrans ou gros textes
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: isSmallHeight ? 4 : 8),
                          Text(
                            pages[_pageIndex].title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: titleFontSize / textScale,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: isSmallHeight ? 8 : 12),
                          Text(
                            pages[_pageIndex].description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: descFontSize / textScale,
                              color: Colors.grey[700],
                              height: 1.35,
                            ),
                          ),

                          SizedBox(height: isVerySmallHeight ? 8 : 16),

                          // Progress bar
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade700,
                            ),
                          ),
                          SizedBox(height: isSmallHeight ? 8 : 12),

                          // Dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              pages.length,
                                  (i) => AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 6),
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

                          SizedBox(height: isSmallHeight ? 12 : 18),

                          // Button principal
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallHeight ? 12 : 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _onNext,
                              child: Text(
                                _pageIndex == pages.length - 1
                                    ? 'Get Started'
                                    : 'Continue',
                                style: TextStyle(
                                  fontSize: buttonFontSize / textScale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallHeight ? 8 : 12),

                          // Skip / Back
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
                                  if (_pageIndex > 0) {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                          milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isVerySmallHeight ? 4 : 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 60);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height,
    );

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
