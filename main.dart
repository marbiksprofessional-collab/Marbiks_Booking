import 'package:flutter/material';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MarbiksLuxuryERP());
}

class MarbiksLuxuryERP extends StatelessWidget {
  const MarbiksLuxuryERP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marbiks Luxury ERP',
      debugShowCheckedModeBanner: false,
      
      // 🌟 Premium Luxury Dark Theme Definition (Apple Style)
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Deep Caviar Jet Black
        primaryColor: const Color(0xFFD4AF37), // Muted Champagne Gold
        textTheme: GoogleFonts.sfProDisplayTextTheme(ThemeData.dark().textTheme).copyWith(
          headlineMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          bodyMedium: const TextStyle(color: Color(0xFFA6A6A6)),
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            '👑 MARBIKS LUXURY ERP\nInitializing Premium Layer...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.w640,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
