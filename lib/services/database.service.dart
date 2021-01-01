import "package:path/path.dart" as path;
import "package:sqflite/sqflite.dart";

import "package:cryptarch/models/models.dart";

const DATABASE_VERSION = 2;

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
        if (oldVersion == 1) {
          await this._migrateV1(db);
        }
      },
    );
    return this._db;
  }

  Database get db {
    return _db;
  }

  Query getQuery(Map<String, dynamic> filters) {
    String where = "";
    List<dynamic> args = [];
    List<String> keys = filters.keys.toList();

    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      dynamic value = filters[key];

      if (key == "orderBy") {
        continue;
      }

      if (value is List) {
        List<String> values = List<String>.from(value);
        List<String> qs = List<String>.filled(values.length, "?");
        where += "$key IN (${qs.join(",")})";
        args.addAll(values);
      } else {
        if (value is bool) {
          value = value ? 1 : 0;
        }
        where += "$key = ?";
        args.add(value);
      }

      if (i < keys.length - 1) {
        where += " AND ";
      }
    }

    return Query(where, args);
  }

  Future<List<Map<String, dynamic>>> find(
    String model,
    List<String> columns,
    Map<String, dynamic> filters, {
    String orderBy,
    int limit,
    int offset,
  }) async {
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
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } else {
      rawModels = await db.query(
        model,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
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

  String _mapToSqlColumnsString(Map<String, String> map) {
    String table = "";
    map.forEach((key, value) {
      table += "$key $value, ";
    });
    table = table.substring(0, table.length - 2);
    return table;
  }

  Future<void> _initializeTables(Database db) async {
    final tables = {
      Asset.tableName: Asset.tableColumns,
      Account.tableName: Account.tableColumns,
      // Energy.tableName: Energy.tableColumns,
      Miner.tableName: Miner.tableColumns,
      Payout.tableName: Payout.tableColumns,
    };
    for (String tableName in tables.keys) {
      String columns = _mapToSqlColumnsString(tables[tableName]);
      await db.execute("CREATE TABLE $tableName ($columns)");
    }
  }

  Future<void> _migrateV1(Database db) async {
    String payoutTable = Payout.tableName;
    String payoutColumns = _mapToSqlColumnsString(Payout.tableColumns);
    await db.execute("CREATE TABLE $payoutTable ($payoutColumns)");
    // String energyTable = Energy.tableName;
    // String energyColumns = _mapToSqlColumnsString(Energy.tableColumns);
    // await db.execute("CREATE TABLE $energyTable ($energyColumns)");
  }
}
