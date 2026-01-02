import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'evaluation_service.dart';

class PdfService {
  /// Generates a comprehensive result PDF with answer comparison
  static Future<String?> generateFullResult({
    required String name,
    required String email,
    required DateTime timestamp,
    required Map<String, dynamic> answersSoFar,
  }) async {
    final pdf = pw.Document();

    // ===== SAFE DATA EXTRACTION =====
    final Map<String, dynamic> sectionADetails =
        EvaluationService.getDetailedSectionAResults(answersSoFar);

    final int sectionAScore = sectionADetails['totalScore'] as int? ?? 0;
    final int sectionAMax = sectionADetails['maxScore'] as int? ?? 0;
    final Map<String, dynamic> breakdown =
        sectionADetails['breakdown'] as Map<String, dynamic>? ?? {};

    // FIX: evaluateSectionB returns a Map<String, int>, not an int
    final Map<String, int> sectionBResults = 
        EvaluationService.evaluateSectionB(answersSoFar);
    
    final int sectionBScore = sectionBResults['totalScore'] ?? 0;
    final int q1Score = sectionBResults['q1Score'] ?? 0;
    final int q2Score = sectionBResults['q2Score'] ?? 0;

    final int totalScore = sectionAScore + sectionBScore;
    final int maxScore = sectionAMax + 10;

    // Extract codes for display
    final String q1Code = answersSoFar['sectionBPreview'] as String? ?? '';
    final String q2Code = answersSoFar['sectionB'] as String? ?? '';

    // ===== PDF PAGE =====
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          _buildHeader(name, email, timestamp, totalScore, maxScore),
          pw.SizedBox(height: 20),
          _buildSectionA(sectionAScore, sectionAMax, breakdown),
          pw.SizedBox(height: 20),
          _buildSectionB(q1Score, q1Code, q2Score, q2Code),
        ],
      ),
    );

    return _savePdf(pdf, name);
  }

  // ================= HEADER =================

  static pw.Widget _buildHeader(String name, String email, DateTime timestamp, int totalScore, int maxScore) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.cyan, width: 2),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('WebArena TagMode - Quiz Result',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Student: $name'),
          pw.Text('Email: $email'),
          pw.Text('Date: ${_formatDateTime(timestamp)}'),
          pw.SizedBox(height: 10),
          pw.Text(
            'Total Score: $totalScore / $maxScore',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: totalScore >= maxScore * 0.6 ? PdfColors.green : PdfColors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION A =================

  static pw.Widget _buildSectionA(int score, int maxScore, Map<String, dynamic> breakdown) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Section A: Multiple Choice & Matching',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Score: $score / $maxScore'),
          pw.SizedBox(height: 10),
          pw.Divider(),
          ..._buildSectionABreakdown(breakdown),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildSectionABreakdown(Map<String, dynamic> breakdown) {
    final List<pw.Widget> widgets = [];
    breakdown.forEach((key, value) {
      if (value == null) return;
      if (key == 'Q5') {
        widgets.add(pw.SizedBox(height: 8));
        widgets.add(pw.Text('Q5: Matching (${value['points']} / ${value['maxPoints']} pts)',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
        final Map matches = value['matches'] as Map? ?? {};
        matches.forEach((tag, matchData) {
          final bool isCorrect = matchData['isCorrect'] ?? false;
          widgets.add(pw.Padding(
            padding: const pw.EdgeInsets.only(left: 15, top: 2),
            child: pw.Text('$tag -> ${matchData['userAnswer']} ${isCorrect ? "✓" : "(X)"}',
                style: pw.TextStyle(fontSize: 10, color: isCorrect ? PdfColors.green : PdfColors.red)),
          ));
        });
      } else {
        final bool isCorrect = value['isCorrect'] ?? false;
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text('$key: ${value['userAnswer']} ${isCorrect ? "✓" : "(Correct: ${value['correctAnswer']})"}',
              style: pw.TextStyle(fontSize: 10, color: isCorrect ? PdfColors.green : PdfColors.red)),
        ));
      }
    });
    return widgets;
  }

  // ================= SECTION B =================

  static pw.Widget _buildSectionB(int q1Score, String q1Code, int q2Score, String q2Code) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Section B: Coding Tasks',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Total Section B Score: ${q1Score + q2Score} / 10'),
          pw.SizedBox(height: 10),
          
          // Q1: Table
          pw.Text('Q1: Table Creation ($q1Score / 5)'),
          _codeBox(q1Code.isEmpty ? 'No answer' : q1Code, q1Score > 0),
          
          pw.SizedBox(height: 10),
          
          // Q2: CSS
          pw.Text('Q2: Inline CSS ($q2Score / 5)'),
          _codeBox(q2Code.isEmpty ? 'No answer' : q2Code, q2Score > 0),
        ],
      ),
    );
  }

  static pw.Widget _codeBox(String code, bool isCorrect) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(6),
      margin: const pw.EdgeInsets.only(top: 4),
      color: isCorrect ? PdfColors.green50 : PdfColors.red50,
      child: pw.Text(code, style: pw.TextStyle(fontSize: 9, font: pw.Font.courier())),
    );
  }

  // ================= SAVE & FORMAT =================

  static Future<String?> _savePdf(pw.Document pdf, String name) async {
    if (kIsWeb) return null;
    final dir = (Platform.isAndroid || Platform.isIOS) 
        ? await getApplicationDocumentsDirectory() 
        : (await getDownloadsDirectory()) ?? await getApplicationDocumentsDirectory();

    final safeName = name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final path = '${dir.path}/${safeName}_result.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }

  static String _formatDateTime(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}