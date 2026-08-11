import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/database_helper.dart';
import '../models/unit_record.dart';
import '../theme.dart';
import '../utils/urdu_format.dart';
import '../services/ocr_service.dart';

class AddUnitScreen extends StatefulWidget {
  final String userName;
  const AddUnitScreen({super.key, required this.userName});

  @override
  State<AddUnitScreen> createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends State<AddUnitScreen> {
  final _nameController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  String? _error;
  int? _total;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
    _startController.addListener(_recalculate);
    _endController.addListener(_recalculate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final start = int.tryParse(_startController.text);
    final end = int.tryParse(_endController.text);
    setState(() {
      _error = null;
      _total = null;
      if (start != null && end != null) {
        try {
          _total = UnitCalculator.calculateTotal(startUnit: start, endUnit: end);
        } on InvalidUnitException catch (e) {
          _error = e.urduMessage;
        }
      }
    });
  }

  Future<void> _captureFromCamera(TextEditingController target) async {
    try {
      final result = await OcrService.captureAndRecognizeMeterReading();
      if (result == null) return;
      target.text = result.value;
      if (!result.confident) {
        _showSnack(OcrService.lowConfidenceMessage);
      }
    } catch (_) {
      _showSnack('تصویر لینے میں مسئلہ پیش آیا');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textAlign: TextAlign.right)),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'نام درج کریں');
      return;
    }
    final start = int.tryParse(_startController.text);
    final end = int.tryParse(_endController.text);
    try {
      final total = UnitCalculator.calculateTotal(startUnit: start, endUnit: end);
      setState(() => _saving = true);
      final record = UnitRecord(
        name: name,
        date: DateTime.now(),
        startUnit: start!,
        endUnit: end!,
        createdAt: DateTime.now(),
      );
      await DatabaseHelper.instance.insertRecord(record);
      await DatabaseHelper.instance.updateLastUsedName(name);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      // Silence unused-total-var lint in some analyzers.
      assert(total >= 0);
    } on InvalidUnitException catch (e) {
      setState(() => _error = e.urduMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = UrduFormat.fullDate(DateTime.now());
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نیا یونٹ شامل کریں')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(today, style: const TextStyle(color: AppColors.greyText, fontSize: 15)),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('نام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(hintText: 'نام'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _unitField(
                label: 'شروع کا یونٹ',
                controller: _startController,
              ),
              const SizedBox(height: 16),
              _unitField(
                label: 'آخری یونٹ',
                controller: _endController,
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
                  ),
                )
              else if (_total != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Text('کل یونٹ', style: TextStyle(color: AppColors.white)),
                      const SizedBox(height: 6),
                      Text(
                        '$_total',
                        style: const TextStyle(color: AppColors.red, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                    : const Text('محفوظ کریں'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitField({required String label, required TextEditingController controller}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: () => _captureFromCamera(controller),
                  tooltip: 'تصویر لیں',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(hintText: 'نمبر درج کریں'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
