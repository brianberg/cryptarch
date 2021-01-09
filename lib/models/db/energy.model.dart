import "package:meta/meta.dart";

import "package:sqflite/sqflite.dart";
import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/services/services.dart" show DatabaseService;

class Energy {
  final String id;
  final Miner miner;
  final double amount;
  final DateTime date;

  static final String tableName = "energy";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "minerId": "TEXT",
    "amount": "REAL",
    "date": "INTEGER",
  };

  Energy({
    @required this.id,
    @required this.miner,
    @required this.amount,
    @required this.date,
  })  : assert(id != null),
        assert(miner != null),
        assert(amount != null),
        assert(date != null);

  double get cost {
    return this.amount * 0.07746;
  }

  static Future<Energy> deserialize(Map<String, dynamic> rawEnergy) async {
    final minerId = rawEnergy["minerId"];
    final amount = rawEnergy["amount"];

    return Energy(
      id: rawEnergy["id"],
      miner: minerId != null ? await Miner.findOneById(minerId) : null,
      amount: amount != null ? amount.toDouble() : null,
      date: DateTime.fromMillisecondsSinceEpoch(rawEnergy["date"]),
    );
  }

  static Future<List<Energy>> find({
    Map<String, dynamic> filters,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final List<Energy> assets = new List();

    final List<Map<String, dynamic>> rawEnergys = await DatabaseService().find(
      Energy.tableName,
      Energy.tableColumns.keys.toList(),
      filters,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    for (Map<String, dynamic> rawEnergy in rawEnergys) {
      Energy asset = await Energy.deserialize(rawEnergy);
      assets.add(asset);
    }

    return assets;
  }

  static Future<Energy> findOneById(String id) async {
    final db = await DatabaseService().connect();
    final rawEnergys = await db.query(
      Energy.tableName,
      columns: Energy.tableColumns.keys.toList(),
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (rawEnergys.isNotEmpty) {
      return Energy.deserialize(rawEnergys.first);
    }

    return null;
  }

  static Future<int> deleteMany(Map<String, dynamic> filters) async {
    return DatabaseService().delete(Energy.tableName, filters);
  }

  Map<String, dynamic> serialize() {
    final map = new Map<String, dynamic>();
    map["id"] = this.id;
    map["minerId"] = this.miner.id;
    map["amount"] = this.amount;
    map["date"] = this.date.millisecondsSinceEpoch;

    return map;
  }

  Future<void> save() async {
    final db = await DatabaseService().connect();
    await db.insert(
      Energy.tableName,
      this.serialize(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    Map<String, dynamic> filters = {};
    filters["id"] = this.id;
    await DatabaseService().delete(Energy.tableName, filters);
  }

  @override
  String toString() => "$amount kWh";
}
