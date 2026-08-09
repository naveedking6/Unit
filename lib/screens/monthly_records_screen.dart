import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/unit_record.dart';
import '../theme.dart';
import '../utils/urdu_format.dart';

/// Book-like monthly records browser — swipe left/right between months.
/// PDF/image export are wired as entry points here (export generation
/// itself lives in export_service.dart, built out separately since it
/// needs Urdu font assets bundled and tested on-device for correct RTL
/// shaping in the PDF).
class MonthlyRecordsScreen extends StatefulWidget {
  final String userName;
  const MonthlyRecordsScreen({super.key, required this.userName});

  @override
  State<MonthlyRecordsScreen> createState() => _MonthlyRecordsScreenState();
}

class _MonthlyRecordsScreenState extends State<MonthlyRecordsScreen> {
  late PageController _pageController;
  late List<(int, int)> _months; // (year, month), oldest -> newest
  int _initialIndex = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final now = DateTime.now();
    var months = await DatabaseHelper.instance.getAvailableMonths();
    months = months.reversed.toList(); // oldest -> newest
    if (months.isEmpty || months.last != (now.year, now.month)) {
      months = [...months, (now.year, now.month)];
    }
    setState(() {
      _months = months;
      _initialIndex = months.length - 1;
      _pageController = PageController(initialPage: _initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || _months.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.red)));
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ماہانہ ریکارڈ')),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _months.length,
          itemBuilder: (context, index) {
            final (year, month) = _months[index];
            return _MonthPage(year: year, month: month, userName: widget.userName);
          },
        ),
      ),
    );
  }
}

class _MonthPage extends StatelessWidget {
  final int year;
  final int month;
  final String userName;
  const _MonthPage({required this.year, required this.month, required this.userName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UnitRecord>>(
      future: DatabaseHelper.instance.getRecordsForMonth(year, month),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.red));
        }
        final records = snapshot.data!;
        final total = records.fold<int>(0, (s, r) => s + r.totalUnit);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              UrduFormat.monthYear(year, month),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PDF بنائیں — جلد شامل کیا جائے گا')),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('PDF بنائیں'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تصویر بنائیں — جلد شامل کیا جائے گا')),
                      );
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('تصویر بنائیں'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text('اس مہینے کوئی ریکارڈ موجود نہیں', style: TextStyle(color: AppColors.greyText)),
                ),
              )
            else
              ...records.map((r) => Card(
                    child: ListTile(
                      title: Text(UrduFormat.fullDate(r.date)),
                      subtitle: Text('${r.startUnit}  →  ${r.endUnit}'),
                      trailing: Text(
                        '${r.totalUnit}',
                        style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  )),
            const SizedBox(height: 16),
            Card(
              color: AppColors.black,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('کل یونٹ', style: TextStyle(color: AppColors.white, fontSize: 18)),
                    Text('$total', style: const TextStyle(color: AppColors.red, fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
