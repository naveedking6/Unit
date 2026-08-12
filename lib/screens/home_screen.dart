import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/unit_record.dart';
import '../services/export_service.dart';
import '../theme.dart';
import '../utils/urdu_format.dart';
import '../widgets/monthly_report_image_widget.dart';
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
  String _currentName = '';
  List<UnitRecord> _records = [];
  int _monthlyTotal = 0;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _currentName = widget.userName;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await DatabaseHelper.instance.getRecordsForMonth(_year, _month);
    final total = await DatabaseHelper.instance.getMonthlyTotal(_year, _month);
    final name = await DatabaseHelper.instance.getName();
    setState(() {
      _records = records;
      _monthlyTotal = total;
      if (name != null && name.isNotEmpty) _currentName = name;
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

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.right)));
  }

  Future<void> _addNewName() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('نیا نام درج کریں'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(hintText: 'نام'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('منسوخ کریں')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('محفوظ کریں'),
            ),
          ],
        ),
      ),
    );
    if (name != null && name.isNotEmpty) {
      await DatabaseHelper.instance.updateLastUsedName(name);
      setState(() => _currentName = name);
    }
  }

  Future<void> _deleteRecord(UnitRecord r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('ریکارڈ حذف کریں؟'),
          content: Text('${r.name} — ${UrduFormat.fullDate(r.date)} کا ریکارڈ حذف کیا جائے؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('منسوخ کریں')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف کریں', style: TextStyle(color: AppColors.red)),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && r.id != null) {
      await DatabaseHelper.instance.deleteRecord(r.id!);
      _load();
    }
  }

  Future<void> _exportPdf() async {
    if (_records.isEmpty) {
      _showSnack('اس مہینے کوئی ریکارڈ موجود نہیں');
      return;
    }
    setState(() => _exporting = true);
    try {
      await ExportService.shareMonthlyReport(
        userName: _currentName,
        year: _year,
        month: _month,
        records: _records,
      );
    } catch (_) {
      _showSnack('PDF بنانے میں مسئلہ پیش آیا');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportImage() async {
    if (_records.isEmpty) {
      _showSnack('اس مہینے کوئی ریکارڈ موجود نہیں');
      return;
    }
    setState(() => _exporting = true);
    try {
      await ExportService.shareMonthlyReportImage(
        userName: _currentName,
        year: _year,
        month: _month,
        records: _records,
      );
    } catch (_) {
      _showSnack('تصویر بنانے میں مسئلہ پیش آیا');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.black),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: const Text('یونٹ ساتھی'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded, color: AppColors.black),
              tooltip: 'ریکارڈز',
              onPressed: () => _openScreen(MonthlyRecordsScreen(userName: _currentName)),
            ),
          ],
        ),
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.calculate_outlined),
                  title: const Text('کیلکولیٹر'),
                  onTap: () {
                    Navigator.pop(context);
                    _openScreen(const CalculatorScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('ریکارڈز'),
                  onTap: () {
                    Navigator.pop(context);
                    _openScreen(MonthlyRecordsScreen(userName: _currentName));
                  },
                ),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.red,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _nameCard(),
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
                _recordsTable(),
              const SizedBox(height: 16),
              _actionRow(),
              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: _bottomNav(),
      ),
    );
  }

  Widget _nameCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            InkWell(
              onTap: _addNewName,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.person_add_alt_1_outlined, color: AppColors.red, size: 20),
                    SizedBox(width: 6),
                    Text('نیا نام درج کریں', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Container(width: 1, height: 32, color: AppColors.grey),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('نام درج کرین', style: TextStyle(color: AppColors.greyText, fontSize: 13)),
                const SizedBox(height: 2),
                Text(_currentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 10),
            const CircleAvatar(
              backgroundColor: AppColors.red,
              radius: 18,
              child: Icon(Icons.person, color: AppColors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthSelector() {
    final isCurrentMonth = _year == DateTime.now().year && _month == DateTime.now().month;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.black),
              onPressed: () => _changeMonth(-1),
              tooltip: 'پچھلا مہینہ',
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    UrduFormat.monthYear(_year, _month),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (isCurrentMonth)
                    const Text('(موجودہ مہینہ)', style: TextStyle(fontSize: 12, color: AppColors.greyText)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.black),
              onPressed: () => _changeMonth(1),
              tooltip: 'اگلا مہینہ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthlyTotalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed_rounded, color: AppColors.red, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('اس مہینے کا کل یونٹ', style: TextStyle(fontSize: 14, color: AppColors.greyText)),
                const SizedBox(height: 2),
                Text(
                  '$_monthlyTotal یونٹ',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordsTable() {
    // Newest first, numbered from the top like the mockup (#1 = most recent).
    final rows = _records.reversed.toList();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey, width: 1),
      ),
      child: Column(
        children: [
          Container(
            color: AppColors.red,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Row(
              children: [
                _HeaderCell('کاروائی', flex: 2),
                _HeaderCell('کل یونٹ', flex: 2),
                _HeaderCell('بند یونٹ', flex: 2),
                _HeaderCell('شروع یونٹ', flex: 2),
                _HeaderCell('تاریخ', flex: 2),
                _HeaderCell('دن', flex: 2),
                _HeaderCell('نام', flex: 2),
                _HeaderCell('#', flex: 1),
              ],
            ),
          ),
          for (int i = 0; i < rows.length; i++)
            Container(
              color: i.isEven ? AppColors.white : AppColors.grey.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                        onPressed: () => _deleteRecord(rows[i]),
                        tooltip: 'حذف کریں',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                  _DataCell('${rows[i].totalUnit}', flex: 2, bold: true, color: AppColors.red),
                  _DataCell('${rows[i].endUnit}', flex: 2),
                  _DataCell('${rows[i].startUnit}', flex: 2),
                  _DataCell('${rows[i].date.day} ${UrduFormat.monthName(rows[i].date.month)}', flex: 2),
                  _DataCell(UrduFormat.dayName(rows[i].date), flex: 2),
                  _DataCell(rows[i].name, flex: 2, bold: true),
                  _DataCell('${i + 1}', flex: 1),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _exporting ? null : _exportImage,
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('تصویر بنائیں'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _exporting ? null : _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('PDF بنائیں'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => AddUnitScreen(userName: _currentName)),
              );
              if (saved == true) _load();
            },
            icon: const Icon(Icons.add),
            label: const Text('نیا یونٹ شامل کریں'),
          ),
        ),
      ],
    );
  }

  Widget _bottomNav() {
    return BottomAppBar(
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.calculate_outlined, 'کیلکولیٹر', () => _openScreen(const CalculatorScreen())),
          _navItem(Icons.ios_share_outlined, 'برآمد کریں', () => _openScreen(MonthlyRecordsScreen(userName: _currentName))),
          _navItem(Icons.home_rounded, 'ہوم', () {}, active: true),
          _navItem(Icons.receipt_long_outlined, 'ریکارڈز', () => _openScreen(MonthlyRecordsScreen(userName: _currentName))),
          _navItem(Icons.calendar_month_outlined, 'کیلنڈر', () => _openScreen(MonthlyRecordsScreen(userName: _currentName))),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback onTap, {bool active = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: active ? 22 : 18,
              backgroundColor: active ? AppColors.red : Colors.transparent,
              child: Icon(icon, color: active ? AppColors.white : AppColors.greyText, size: active ? 24 : 22),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: active ? AppColors.red : AppColors.greyText)),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool bold;
  final Color? color;
  const _DataCell(this.text, {required this.flex, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppColors.black,
          ),
        ),
      ),
    );
  }
}
