import 'package:flutter/material.dart';
import '../theme.dart';

/// A small, independent calculator — deliberately not scientific.
/// Kept fully separate from the unit-record system per spec.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';

  void _onKey(String key) {
    setState(() {
      if (key == 'C') {
        _expression = '';
        _result = '0';
      } else if (key == '=') {
        _result = _evaluate(_expression);
      } else {
        _expression += key;
      }
    });
  }

  String _evaluate(String expr) {
    try {
      // Minimal left-to-right evaluator for +, -, *, /  (no precedence needed
      // for a basic meter-difference calculator; keeps this dependency-free).
      final tokens = RegExp(r'(\d+\.?\d*|[+\-*/])').allMatches(expr).map((m) => m.group(0)!).toList();
      if (tokens.isEmpty) return '0';
      double acc = double.parse(tokens[0]);
      for (int i = 1; i < tokens.length - 1; i += 2) {
        final op = tokens[i];
        final val = double.parse(tokens[i + 1]);
        switch (op) {
          case '+': acc += val; break;
          case '-': acc -= val; break;
          case '*': acc *= val; break;
          case '/': acc = val == 0 ? double.nan : acc / val; break;
        }
      }
      if (acc.isNaN) return 'نامعلوم';
      return acc == acc.roundToDouble() ? acc.toInt().toString() : acc.toString();
    } catch (_) {
      return 'نامعلوم';
    }
  }

  static const _keys = [
    ['7', '8', '9', '/'],
    ['4', '5', '6', '*'],
    ['1', '2', '3', '-'],
    ['C', '0', '=', '+'],
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('کیلکولیٹر')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_expression, style: const TextStyle(fontSize: 18, color: AppColors.greyText)),
                    const SizedBox(height: 6),
                    Text(_result, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ..._keys.map((row) => Expanded(
                    child: Row(
                      children: row.map((k) => Expanded(child: _key(k))).toList(),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _key(String label) {
    final isOp = ['/', '*', '-', '+', '='].contains(label);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOp ? AppColors.red : AppColors.white,
          foregroundColor: isOp ? AppColors.white : AppColors.black,
          side: isOp ? null : const BorderSide(color: AppColors.grey, width: 2),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _onKey(label),
        child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
