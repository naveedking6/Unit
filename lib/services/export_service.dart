import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/unit_record.dart';
import '../utils/urdu_format.dart';

/// Builds and shares/prints a one-month PDF report. Runs entirely offline —
/// `printing`'s share sheet uses the OS share/print dialog, no network call.
class ExportService {
  static pw.Font? _urduFont;
  static pw.Font? _urduFontBold;

  static Future<void> _loadFont() async {
    if (_urduFont != null) return;
    final data = await rootBundle.load('assets/fonts/NotoNastaliqUrdu.ttf');
    // Same variable-font file works for both; the PDF renderer just uses
    // the font's default (regular) instance for both roles here since the
    // file doesn't expose separate static regular/bold sub-fonts.
    _urduFont = pw.Font.ttf(data);
    _urduFontBold = pw.Font.ttf(data);
  }

  /// Generates the PDF bytes for a given month's records.
  static Future<Uint8List> buildMonthlyReportPdf({
    required String userName,
    required int year,
    required int month,
    required List<UnitRecord> records,
  }) async {
    await _loadFont();
    final doc = pw.Document();
    final total = records.fold<int>(0, (s, r) => s + r.totalUnit);

    final theme = pw.ThemeData.withFont(base: _urduFont!, bold: _urduFontBold!);

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'یونٹ ساتھی',
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#E0201B')),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Center(child: pw.Text('نام: $userName', style: const pw.TextStyle(fontSize: 16))),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(UrduFormat.monthYear(year, month), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex('#161616'), width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex('#161616')),
                children: [
                  _cell('تاریخ', header: true),
                  _cell('شروع کا یونٹ', header: true),
                  _cell('آخری یونٹ', header: true),
                  _cell('کل یونٹ', header: true),
                ],
              ),
              for (final r in records)
                pw.TableRow(
                  children: [
                    _cell(UrduFormat.fullDate(r.date)),
                    _cell('${r.startUnit}'),
                    _cell('${r.endUnit}'),
                    _cell('${r.totalUnit}'),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(color: PdfColor.fromHex('#161616'), borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('کل یونٹ', style: const pw.TextStyle(color: PdfColors.white, fontSize: 16)),
                pw.Text('$total', style: pw.TextStyle(color: PdfColor.fromHex('#E0201B'), fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _cell(String text, {bool header = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 12,
          color: header ? PdfColors.white : PdfColors.black,
          fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Shows the OS print/share sheet for the given month — user can save,
  /// print, or share as a PDF file.
  static Future<void> shareMonthlyReport({
    required String userName,
    required int year,
    required int month,
    required List<UnitRecord> records,
  }) async {
    final bytes = await buildMonthlyReportPdf(
      userName: userName,
      year: year,
      month: month,
      records: records,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'unit-saathi-${UrduFormat.monthName(month)}-$year.pdf',
    );
  }
}
