// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅Barre de statut transparente pour toute l’app
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,      // pas de bande de couleur
      statusBarIconBrightness: Brightness.dark, // icônes sombres (sur fond clair)
    ),
  );

  runApp(const SmartCityApp());
}

class SmartCityApp extends StatelessWidget {
  const SmartCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SmartCity',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),

      /// ✅ Ici on coupe le padding top du système pour TOUTE l’app
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            // on garde bottom (pour la barre de gestes), mais on remet top à 0
            padding: mediaQuery.padding.copyWith(top: 0),
            viewPadding: mediaQuery.viewPadding.copyWith(top: 0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      routerConfig: appRouter,
    );
  }
}
