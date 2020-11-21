import "package:path/path.dart" as path;
import "package:sqflite/sqflite.dart";

import "package:cryptarch/models/models.dart";

const DATABASE_VERSION = 1;

class Query {
  final String where;
  final List<dynamic> args;

  Query(this.where, this.args);
}

class DatabaseService {
  static final DatabaseService _dbService = DatabaseService._internal();

  Database _db;

  factory DatabaseService.register() {
    return _dbService;
  }

  factory DatabaseService() {
    return _dbService;
  }

  DatabaseService._internal();

  Future<Database> connect() async {
    if (this._db != null) {
      return this._db;
    }
    final String dir = await getDatabasesPath();
    final String dbPath = path.join(dir, "cryptarch.db");
    this._db = await openDatabase(
      dbPath,
      version: DATABASE_VERSION,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await this._initializeTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Migrations
      },
    );
    return this._db;
  }

  Database get db {
    return _db;
  }

  Query getQuery(Map<String, dynamic> filters) {
    String query = "";
    List<dynamic> args = [];
    List<String> keys = filters.keys.toList();

    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      dynamic value = filters[key];

      if (value is List) {
        List<String> values = List<String>.from(value);
        List<String> qs = List<String>.filled(values.length, "?");
        query += "$key IN (${qs.join(",")})";
        args.addAll(values);
      } else {
        if (value is bool) {
          value = value ? 1 : 0;
        }
        query += "$key = ?";
        args.add(value);
      }

      if (i < keys.length - 1) {
        query += " AND ";
      }
    }

    return Query(query, args);
  }

  Future<List<Map<String, dynamic>>> find(
    String model,
    List<String> columns,
    Map<String, dynamic> filters,
  ) async {
    final db = await this.connect();
    Query query;
    List<Map<String, dynamic>> rawModels;
    if (filters != null && filters.keys.isNotEmpty) {
      query = this.getQuery(filters);
      rawModels = await db.query(
        model,
        columns: columns,
        where: query.where,
        whereArgs: query.args,
      );
    } else {
      rawModels = await db.query(model);
    }

    return rawModels;
  }

  Future<int> delete(
    String model,
    Map<String, dynamic> filters,
  ) async {
    final db = await this.connect();
    Query query;
    int numDeleted;
    if (filters != null && filters.keys.isNotEmpty) {
      query = this.getQuery(filters);
      numDeleted = await db.delete(
        model,
        where: query.where,
        whereArgs: query.args,
      );
    } else {
      throw "DELETE operation requires query arguments";
    }

    return numDeleted;
  }

  String _mapToSqlTableString(Map<String, String> map) {
    String table = "";
    map.forEach((key, value) {
      table += "$key $value, ";
    });
    table = table.substring(0, table.length - 2);
    return table;
  }

  Future<void> _initializeTables(Database db) async {
    String assetTable = Asset.tableName;
    String assetColumns = _mapToSqlTableString(Asset.tableColumns);
    await db.execute("CREATE TABLE $assetTable ($assetColumns)");
    String accountTable = Account.tableName;
    String accountColumns = _mapToSqlTableString(Account.tableColumns);
    await db.execute("CREATE TABLE $accountTable ($accountColumns)");
    String minerTable = Miner.tableName;
    String minerColumns = _mapToSqlTableString(Miner.tableColumns);
    await db.execute("CREATE TABLE $minerTable ($minerColumns)");
  }
}
