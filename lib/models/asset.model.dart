import "package:meta/meta.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/services/services.dart" show DatabaseService;

class Asset {
  final String id;
  final String name;
  final String symbol;
  double value;
  String exchange;
  String tokenPlatform;
  String contractAddress;
  double lastPrice;
  double highPrice;
  double lowPrice;
  double percentChange;

  static final String tableName = "assets";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "name": "TEXT",
    "symbol": "TEXT",
    "value": "REAL",
    "exchange": "TEXT",
    "tokenPlatform": "TEXT",
    "contractAddress": "TEXT",
    "lastPrice": "REAL",
    "highPrice": "REAL",
    "lowPrice": "REAL",
    "percentChange": "REAL",
  };

  Asset({
    @required this.id,
    @required this.name,
    @required this.symbol,
    @required this.value,
    this.exchange,
    this.tokenPlatform,
    this.contractAddress,
    this.lastPrice,
    this.highPrice,
    this.lowPrice,
    this.percentChange,
  })  : assert(id != null),
        assert(name != null),
        assert(symbol != null),
        assert(value != null);

  static Future<Asset> deserialize(Map<String, dynamic> rawAsset) async {
    final value = rawAsset["value"];
    final lastPrice = rawAsset["lastPrice"];
    final highPrice = rawAsset["highPrice"];
    final lowPrice = rawAsset["lowPrice"];
    final percentChange = rawAsset["percentChange"];

    return Asset(
      id: rawAsset["id"],
      name: rawAsset["name"],
      symbol: rawAsset["symbol"],
      value: value != null ? value.toDouble() : 0.0,
      exchange: rawAsset["exchange"],
      tokenPlatform: rawAsset["tokenPlatform"],
      contractAddress: rawAsset["contractAddress"],
      lastPrice: lastPrice != null ? lastPrice.toDouble() : 0.0,
      highPrice: highPrice != null ? highPrice.toDouble() : 0.0,
      lowPrice: lowPrice != null ? lowPrice.toDouble() : 0.0,
      percentChange: percentChange != null ? percentChange.toDouble() : 0.0,
    );
  }

  static Future<List<Asset>> find({Map<String, dynamic> filters}) async {
    final List<Asset> assets = new List();

    final List<Map<String, dynamic>> rawAssets = await DatabaseService().find(
      Asset.tableName,
      Asset.tableColumns.keys.toList(),
      filters,
    );

    for (Map<String, dynamic> rawAsset in rawAssets) {
      Asset price = await Asset.deserialize(rawAsset);
      assets.add(price);
    }

    return assets;
  }

  static Future<Asset> findOneById(String id) async {
    final db = await DatabaseService().connect();
    final rawAssets = await db.query(
      Asset.tableName,
      columns: Asset.tableColumns.keys.toList(),
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (rawAssets.isNotEmpty) {
      return Asset.deserialize(rawAssets.first);
    }

    return null;
  }

  static Future<Asset> findOneBySymbol(String symbol) async {
    final db = await DatabaseService().connect();
    final rawAssets = await db.query(
      Asset.tableName,
      columns: Asset.tableColumns.keys.toList(),
      where: "symbol = ?",
      whereArgs: [symbol],
      limit: 1,
    );
    if (rawAssets.isNotEmpty) {
      return Asset.deserialize(rawAssets.first);
    }

    return null;
  }

  Map<String, dynamic> serialize() {
    final map = new Map<String, dynamic>();
    map["id"] = this.id;
    map["name"] = this.name;
    map["symbol"] = this.symbol;
    map["value"] = this.value;
    map["exchange"] = this.exchange;
    map["tokenPlatform"] = this.tokenPlatform;
    map["contractAddress"] = this.contractAddress;
    map["lastPrice"] = this.lastPrice;
    map["highPrice"] = this.highPrice;
    map["lowPrice"] = this.lowPrice;
    map["percentChange"] = this.percentChange;

    return map;
  }

  Future<void> save() async {
    final db = await DatabaseService().connect();
    await db.insert(
      Asset.tableName,
      this.serialize(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    Map<String, dynamic> filters = {};
    filters["id"] = this.id;
    await DatabaseService().delete(Asset.tableName, filters);
  }

  @override
  String toString() => "$name";
}
