// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Simple App Constants - inline to avoid import issues
class DbAppConstants {
  static const String databaseName = 'wages.db';
  static const int databaseVersion = 1;
  static const String syncStatusSynced = 'synced';
  static const String syncStatusPending = 'pending';
  static const String syncStatusFailed = 'failed';
}

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;
  
  LocalDatabase._internal();
  
  factory LocalDatabase() => _instance;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, DbAppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: DbAppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Employees table
    await db.execute('''
      CREATE TABLE local_employees (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        hourly_rate_cents INTEGER NOT NULL,
        overtime_rate_cents INTEGER NOT NULL,
        overtime_multiplier REAL NOT NULL,
        notes TEXT,
        active INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT '${DbAppConstants.syncStatusSynced}',
        sync_error TEXT
      )
    ''');
    
    // Work records table
    await db.execute('''
      CREATE TABLE local_work_records (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        employee_id TEXT NOT NULL,
        work_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        break_minutes INTEGER NOT NULL,
        overtime_mode TEXT NOT NULL,
        regular_minutes INTEGER NOT NULL,
        overtime_minutes INTEGER NOT NULL,
        total_minutes INTEGER NOT NULL,
        hourly_rate_cents INTEGER NOT NULL,
        overtime_rate_cents INTEGER NOT NULL,
        bonus_cents INTEGER NOT NULL,
        deductions_cents INTEGER NOT NULL,
        regular_pay_cents INTEGER NOT NULL,
        overtime_pay_cents INTEGER NOT NULL,
        gross_pay_cents INTEGER NOT NULL,
        net_pay_cents INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT '${DbAppConstants.syncStatusSynced}',
        sync_error TEXT
      )
    ''');
    
    // Settings table
    await db.execute('''
      CREATE TABLE local_settings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL UNIQUE,
        currency TEXT NOT NULL,
        default_hourly_rate_cents INTEGER NOT NULL,
        default_overtime_multiplier REAL NOT NULL,
        default_break_minutes INTEGER NOT NULL,
        default_regular_threshold_minutes INTEGER NOT NULL,
        time_format TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT '${DbAppConstants.syncStatusSynced}',
        sync_error TEXT
      )
    ''');
    
    // Sync metadata table
    await db.execute('''
      CREATE TABLE sync_metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
        last_sync_at TEXT,
        sync_version INTEGER NOT NULL DEFAULT 1
      )
    ''');
    
    // Create indexes for performance
    await db.execute('CREATE INDEX idx_local_employees_user_id ON local_employees(user_id)');
    await db.execute('CREATE INDEX idx_local_employees_deleted_at ON local_employees(deleted_at)');
    await db.execute('CREATE INDEX idx_local_work_records_user_id ON local_work_records(user_id)');
    await db.execute('CREATE INDEX idx_local_work_records_employee_id ON local_work_records(employee_id)');
    await db.execute('CREATE INDEX idx_local_work_records_work_date ON local_work_records(work_date)');
    await db.execute('CREATE INDEX idx_local_work_records_deleted_at ON local_work_records(deleted_at)');
    await db.execute('CREATE INDEX idx_local_settings_user_id ON local_settings(user_id)');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
      // await db.execute('ALTER TABLE local_employees ADD COLUMN new_column TEXT');
    }
  }
  
  Future<void> clearUserData(String userId) async {
    final db = await database;
    await db.delete('local_employees', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('local_work_records', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('local_settings', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('sync_metadata', where: 'user_id = ?', whereArgs: [userId]);
  }
  
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('local_employees');
    await db.delete('local_work_records');
    await db.delete('local_settings');
    await db.delete('sync_metadata');
  }
  
  Future<void> close() async {
    final Database? db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}