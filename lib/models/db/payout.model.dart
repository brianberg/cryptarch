import "package:meta/meta.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/models/models.dart" show Asset, Miner;
import "package:cryptarch/services/services.dart" show DatabaseService;

class Payout {
  final String id;
  final Miner miner;
  final Asset asset;
  final double amount;
  final DateTime date;

  static final String tableName = "payouts";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "minerId": "TEXT",
    "assetId": "TEXT",
    "amount": "REAL",
    "date": "INTEGER",
  };

  Payout({
    @required this.id,
    @required this.miner,
    @required this.asset,
    @required this.amount,
    @required this.date,
  })  : assert(id != null),
        assert(miner != null),
        assert(asset != null),
        assert(amount != null),
        assert(date != null);

  static Future<Payout> deserialize(Map<String, dynamic> rawPayout) async {
    final minerId = rawPayout["minerId"];
    final assetId = rawPayout["assetId"];
    final amount = rawPayout["amount"];

    return Payout(
      id: rawPayout["id"],
      miner: minerId != null ? await Miner.findOneById(minerId) : null,
      asset: assetId != null ? await Asset.findOneById(assetId) : null,
      amount: amount != null ? amount.toDouble() : null,
      date: DateTime.parse(rawPayout["date"]),
    );
  }

  static Future<List<Payout>> find({
    Map<String, dynamic> filters,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final List<Payout> assets = new List();

    final List<Map<String, dynamic>> rawPayouts = await DatabaseService().find(
      Payout.tableName,
      Payout.tableColumns.keys.toList(),
      filters,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    for (Map<String, dynamic> rawPayout in rawPayouts) {
      Payout asset = await Payout.deserialize(rawPayout);
      assets.add(asset);
    }

    return assets;
  }

  static Future<Payout> findOneById(String id) async {
    final db = await DatabaseService().connect();
    final rawPayouts = await db.query(
      Payout.tableName,
      columns: Payout.tableColumns.keys.toList(),
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (rawPayouts.isNotEmpty) {
      return Payout.deserialize(rawPayouts.first);
    }

    return null;
  }

  Map<String, dynamic> serialize() {
    final map = new Map<String, dynamic>();
    map["id"] = this.id;
    map["minerId"] = this.miner.id;
    map["assetId"] = this.asset.id;
    map["amount"] = this.amount;
    map["date"] = this.date.millisecondsSinceEpoch;

    return map;
  }

  Future<void> save() async {
    final db = await DatabaseService().connect();
    await db.insert(
      Payout.tableName,
      this.serialize(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    Map<String, dynamic> filters = {};
    filters["id"] = this.id;
    await DatabaseService().delete(Payout.tableName, filters);
  }

  @override
  String toString() => "$amount ${asset.symbol}";
}
