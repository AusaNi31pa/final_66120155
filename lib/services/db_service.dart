import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/incident.dart';

class DBService {
  static final DBService instance = DBService._init();
  static Database? _database;

  DBService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('final_exam_v5.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {

    await db.execute('''
      CREATE TABLE polling_station (
        station_id INTEGER PRIMARY KEY,
        station_name TEXT,
        zone TEXT,
        province TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE violation_type (
        type_id INTEGER PRIMARY KEY,
        type_name TEXT,
        severity TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE incident_report (
        report_id INTEGER PRIMARY KEY AUTOINCREMENT,
        station_id TEXT,
        station_name TEXT,
        zone TEXT,
        province TEXT,
        type_id INTEGER,
        severity TEXT,
        reporter_name TEXT,
        description TEXT,
        evidence_photo TEXT,
        timestamp TEXT,
        ai_result TEXT,
        ai_confidence REAL,
        syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY (type_id) REFERENCES violation_type (type_id)
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {

    await db.insert('polling_station', {
      'station_id': 101,
      'station_name': 'โรงเรียนวัดพระมหาธาตุ',
      'zone': 'เขต 1',
      'province': 'นครศรีธรรมราช'
    });

    await db.insert('polling_station', {
      'station_id': 102,
      'station_name': 'เต็นท์หน้าตลาดท่าวัง',
      'zone': 'เขต 1',
      'province': 'นครศรีธรรมราช'
    });

    await db.insert('polling_station', {
      'station_id': 103,
      'station_name': 'ศาลากลางหมู่บ้านคีรีวง',
      'zone': 'เขต 2',
      'province': 'นครศรีธรรมราช'
    });

    await db.insert('polling_station', {
      'station_id': 104,
      'station_name': 'หอประชุมอำเภอทุ่งสง',
      'zone': 'เขต 3',
      'province': 'นครศรีธรรมราช'
    });

    await db.insert('violation_type', {
      'type_id': 1,
      'type_name': 'ซื้อสิทธิ์ขายเสียง (Buying Votes)',
      'severity': 'High'
    });

    await db.insert('violation_type', {
      'type_id': 2,
      'type_name': 'ขนคนไปลงคะแนน (Transportation)',
      'severity': 'High'
    });

    await db.insert('violation_type', {
      'type_id': 3,
      'type_name': 'หาเสียงเกินเวลา (Overtime Campaign)',
      'severity': 'Medium'
    });

    await db.insert('violation_type', {
      'type_id': 4,
      'type_name': 'ทำลายป้ายหาเสียง (Vandalism)',
      'severity': 'Low'
    });

    await db.insert('violation_type', {
      'type_id': 5,
      'type_name': 'เจ้าหน้าที่วางตัวไม่เป็นกลาง (Bias Official)',
      'severity': 'High'
    });
  }

  Future<int> insertIncident(Incident incident) async {
    final db = await instance.database;
    return await db.insert('incident_report', incident.toMap());
  }

  Future<List<Incident>> getIncidents() async {
    final db = await instance.database;
    final result = await db.query('incident_report');
    return result.map((map) => Incident.fromMap(map)).toList();
  }

  Future<int> getOfflineIncidentsCount() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM incident_report WHERE syncStatus = 0'
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTop3ComplainedStations() async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT station_name, COUNT(report_id) as report_count
      FROM incident_report
      GROUP BY station_name
      ORDER BY report_count DESC
      LIMIT 3
    ''');
  }

  Future<List<Map<String, dynamic>>> getPollingStations() async {
    final db = await instance.database;
    return await db.query('polling_station');
  }

  Future<List<Map<String, dynamic>>> getViolationTypes() async {
    final db = await instance.database;
    return await db.query('violation_type');
  }

  Future<int> updateIncident(Incident incident) async {
    final db = await instance.database;

    return await db.update(
      'incident_report',
      incident.toMap(),
      where: 'report_id = ?',
      whereArgs: [incident.reportId],
    );
  }

  Future<int> deleteIncident(int id) async {
    final db = await instance.database;

    return await db.delete(
      'incident_report',
      where: 'report_id = ?',
      whereArgs: [id],
    );
  }
}