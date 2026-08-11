import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/unit_record.dart';

/// Local-only persistence. No network calls. Data survives app restarts,
/// phone reboots, and month changes. Nothing is ever auto-deleted.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'unit_saathi.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE unit_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            start_unit INTEGER NOT NULL,
            end_unit INTEGER NOT NULL,
            total_unit INTEGER NOT NULL,
            meter_image_path TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ---- User name (not an account — just a locally saved display name) ----

  Future<void> saveName(String name) async {
    final db = await database;
    await db.delete('user_profile');
    await db.insert('user_profile', {'name': name});
  }

  /// Alias — called after saving a record with a possibly different name,
  /// so the next entry defaults to whoever typed most recently.
  Future<void> updateLastUsedName(String name) => saveName(name);

  Future<String?> getName() async {
    final db = await database;
    final rows = await db.query('user_profile', limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['name'] as String;
  }

  // ---- Unit records ----

  Future<int> insertRecord(UnitRecord record) async {
    final db = await database;
    return db.insert('unit_records', record.toMap()..remove('id'));
  }

  Future<List<UnitRecord>> getRecordsForMonth(int year, int month) async {
    final db = await database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();
    final rows = await db.query(
      'unit_records',
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy: 'date ASC',
    );
    return rows.map((r) => UnitRecord.fromMap(r)).toList();
  }

  /// Distinct (year, month) pairs that have at least one record, newest first.
  Future<List<(int, int)>> getAvailableMonths() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT strftime('%Y', date) as y, strftime('%m', date) as m
      FROM unit_records
      ORDER BY y DESC, m DESC
    ''');
    return rows
        .map((r) => (int.parse(r['y'] as String), int.parse(r['m'] as String)))
        .toList();
  }

  Future<int> getMonthlyTotal(int year, int month) async {
    final records = await getRecordsForMonth(year, month);
    return records.fold<int>(0, (sum, r) => sum + r.totalUnit);
  }

  Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete('unit_records', where: 'id = ?', whereArgs: [id]);
  }
}
