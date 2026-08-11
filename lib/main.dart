import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const UnitSaathiApp());
}

class UnitSaathiApp extends StatelessWidget {
  const UnitSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'یونٹ ساتھی',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: const Locale('ur'),
      supportedLocales: const [Locale('ur'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
