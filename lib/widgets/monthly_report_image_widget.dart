import 'package:flutter/material.dart';
import '../models/unit_record.dart';
import '../theme.dart';
import '../utils/urdu_format.dart';

/// The visual layout captured as a shareable image (WhatsApp-friendly).
/// Kept as a real widget (not hand-drawn canvas) so it reuses the app's
/// theme and font automatically.
class MonthlyReportImageWidget extends StatelessWidget {
  final String userName;
  final int year;
  final int month;
  final List<UnitRecord> records;

  const MonthlyReportImageWidget({
    super.key,
    required this.userName,
    required this.year,
    required this.month,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final total = records.fold<int>(0, (s, r) => s + r.totalUnit);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 600,
        color: AppColors.white,
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'یونٹ ساتھی',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.red),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(UrduFormat.monthYear(year, month), style: const TextStyle(fontSize: 16, color: AppColors.greyText)),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(border: Border.all(color: AppColors.grey, width: 2), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  for (final r in records) _row(UrduFormat.fullDate(r.date), r.startUnit, r.endUnit, r.totalUnit),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('کل یونٹ', style: TextStyle(color: AppColors.white, fontSize: 18)),
                  Text('$total', style: const TextStyle(color: AppColors.red, fontSize: 26, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String date, int start, int end, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.grey, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 3, child: Text(date, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text('$start → $end', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.greyText))),
          Expanded(flex: 1, child: Text('$total', textAlign: TextAlign.left, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.red))),
        ],
      ),
    );
  }
}
