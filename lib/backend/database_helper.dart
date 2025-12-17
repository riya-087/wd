import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'exam_results.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE results(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_name TEXT,
            student_email TEXT,
            sectionA_score INTEGER,
            sectionA_answers TEXT,
            sectionB_score INTEGER,
            sectionB_answer TEXT,
            submitted_at TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertResult({
    required String name,
    required String email,
    required int sectionAScore,
    required Map<String, dynamic> sectionAAnswers,
    required int sectionBScore,
    required String sectionBAnswer,
  }) async {
    final db = await database;
    await db.insert('results', {
      'student_name': name,
      'student_email': email,
      'sectionA_score': sectionAScore,
      'sectionA_answers': jsonEncode(sectionAAnswers),
      'sectionB_score': sectionBScore,
      'sectionB_answer': sectionBAnswer,
      'submitted_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllResults() async {
    final db = await database;
    final results = await db.query('results', orderBy: 'id DESC');
    return results.map((row) {
      return {
        ...row,
        'sectionA_answers': jsonDecode(row['sectionA_answers'] as String)
      };
    }).toList();
  }
}
