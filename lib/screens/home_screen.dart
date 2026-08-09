import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/unit_record.dart';
import '../theme.dart';
import '../utils/urdu_format.dart';
import 'add_unit_screen.dart';
import 'calculator_screen.dart';
import 'monthly_records_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _year;
  late int _month;
  List<UnitRecord> _records = [];
  int _monthlyTotal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await DatabaseHelper.instance.getRecordsForMonth(_year, _month);
    final total = await DatabaseHelper.instance.getMonthlyTotal(_year, _month);
    setState(() {
      _records = records;
      _monthlyTotal = total;
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      final newDate = DateTime(_year, _month + delta, 1);
      _year = newDate.year;
      _month = newDate.month;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('یونٹ ساتھی'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calculate_outlined, color: AppColors.black),
              tooltip: 'کیلکولیٹر',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalculatorScreen()),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: AppColors.red,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _monthSelector(),
              const SizedBox(height: 16),
              _monthlyTotalCard(),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.red),
                ))
              else if (_records.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      'اس مہینے کوئی ریکارڈ موجود نہیں',
                      style: TextStyle(color: AppColors.greyText, fontSize: 16),
                    ),
                  ),
                )
              else
                ..._records.reversed.map(_recordCard),
              const SizedBox(height: 90),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.red,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.add),
          label: const Text('نیا یونٹ شامل کریں'),
          onPressed: () async {
            final saved = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => AddUnitScreen(userName: widget.userName),
              ),
            );
            if (saved == true) _load();
          },
        ),
      ),
    );
  }

  Widget _monthSelector() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.black),
          onPressed: () => _changeMonth(-1),
          tooltip: 'پچھلا',
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MonthlyRecordsScreen(userName: widget.userName)),
            ),
            child: Center(
              child: Text(
                UrduFormat.monthYear(_year, _month),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.black),
          onPressed: () => _changeMonth(1),
          tooltip: 'اگلا',
        ),
      ],
    );
  }

  Widget _monthlyTotalCard() {
    return Card(
      color: AppColors.black,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('کل یونٹ', style: TextStyle(color: AppColors.white, fontSize: 18)),
            Text(
              '$_monthlyTotal',
              style: const TextStyle(color: AppColors.red, fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordCard(UnitRecord r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(UrduFormat.fullDate(r.date), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${r.startUnit}  →  ${r.endUnit}', style: const TextStyle(color: AppColors.greyText)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${r.totalUnit}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
