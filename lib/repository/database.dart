import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    return _database ?? await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'posconfig.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute(
        'CREATE TABLE pos (posid int, posname varchar(10), serial varchar(20), min varchar(50), ptu varchar(50))');
    print('done creating pos table');
    await db.execute(
          'CREATE TABLE store (storeid varchar(5), storename varchar(300), address varchar(300), contact varchar(13), logo TEXT, message TEXT)');
    print('done creating store table');
    await db.execute(
        'CREATE TABLE email (emailaddress varchar(300), emailpassword varchar(300), emailserver varchar(300))');
    print('done creating email table');
  }

  Future<int> insertItem(Map<String, dynamic> item, String tablename) async {
    Database db = await database;
    return await db.insert('$tablename', item);
  }

  Future<void> updateItem(Map<String, dynamic> data, String tablename,
      String condition, dynamic agrs) async {
    Database db = await database;

    await db.update(tablename, data, where: condition, whereArgs: [agrs]);
  }
}
