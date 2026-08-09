import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme.dart';
import 'home_screen.dart';

class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  final _controller = TextEditingController();

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    await DatabaseHelper.instance.saveName(name);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(userName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.red, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'یونٹ ساتھی میں خوش آمدید',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اپنا نام درج کریں',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.greyText),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.right,
                  autofocus: true,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(hintText: 'نام'),
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('محفوظ کریں'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
