import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme.dart';
import 'name_entry_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final name = await DatabaseHelper.instance.getName();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => (name == null || name.trim().isEmpty)
            ? const NameEntryScreen()
            : HomeScreen(userName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.red, size: 72),
            const SizedBox(height: 12),
            const Text(
              'یونٹ ساتھی',
              style: TextStyle(
                fontFamily: 'NotoNastaliqUrdu',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.red),
          ],
        ),
      ),
    );
  }
}
