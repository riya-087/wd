import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PdfService {
  /// Generates and saves a PDF to the Downloads folder
  /// Returns the saved file path
  static Future<String?> generateFullResult({
    required String name,
    required String email,
    required DateTime timestamp,
    required Map<String, dynamic> sectionA,
    required Map<String, dynamic> sectionB,
  }) async {
    final pdf = pw.Document();

    // Build PDF content
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Student: $name', style: pw.TextStyle(fontSize: 18)),
          pw.Text('Email: $email'),
          pw.Text('Timestamp: ${timestamp.toIso8601String()}'),
          pw.SizedBox(height: 20),

          // Section A
          pw.Text('Section A (Quiz 1–5)', style: pw.TextStyle(fontSize: 16)),
          pw.Text('Marks: ${sectionA['marks']}'),
          ...((sectionA['userAnswers'] as Map<String, dynamic>).entries.map((e) {
            final correct = (sectionA['correctAnswers'] as Map<String, dynamic>)[e.key] ?? '';
            return pw.Text('${e.key} Correct: $correct | User: ${e.value}');
          }).toList()),
          pw.SizedBox(height: 20),

          // Section B
          pw.Text('Section B (Coding Task)', style: pw.TextStyle(fontSize: 16)),
          pw.Text('Marks: ${sectionB['marks']}'),
          pw.Text('Correct Answer: ${sectionB['correctAnswer']}'),
          pw.Text('User Answer: ${sectionB['userAnswer']}'),
        ],
      ),
    );

    String? downloadsPath;

    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final dir = await getDownloadsDirectory();
        downloadsPath = dir?.path;
      } else {
        final dir = await getApplicationDocumentsDirectory();
        downloadsPath = dir.path;
      }
    }

    if (downloadsPath == null) return null;

    // Safe file name
    final safeName = name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final timestampStr = DateTime.now().millisecondsSinceEpoch;
    final filePath = '$downloadsPath/${safeName}_$timestampStr-result.pdf';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print("PDF saved at: $filePath");
    return filePath;
  }
}
