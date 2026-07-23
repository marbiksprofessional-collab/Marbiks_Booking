import 'package:flutter/material';
import 'login_screen.dart'; // Import the new luxury login screen template configuration

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
                              
                                    // Complete dark theme token framework integration parameters
                                          theme: ThemeData(
                                                  brightness: Brightness.dark,
                                                          scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Deep Caviar Jet Black
                                                                  primaryColor: const Color(0xFFD4AF37), // Muted Champagne Gold
                                                                        ),
                                                                              home: const MarbiksLoginScreen(), // Set login screen as default landing route context
                                                                                  );
                                                                                    }
                                                                                    }
                                                                                    