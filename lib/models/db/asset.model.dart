import "package:meta/meta.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/services/services.dart" show DatabaseService;

class Asset {
  final String id;
  final String name;
  final String symbol;
  final String type; // fiat, coin, token, nft
  double value;
  String exchange;
  String blockchain;
  String contractAddress;
  String tokenId;
  double lastPrice;
  double highPrice;
  double lowPrice;
  double percentChange;

  static final String tableName = "assets";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "name": "TEXT",
    "symbol": "TEXT",
    "type": "TEXT",
    "value": "REAL",
    "exchange": "TEXT",
    "blockchain": "TEXT",
    "contractAddress": "TEXT",
    "tokenId": "TEXT",
    "lastPrice": "REAL",
    "highPrice": "REAL",
    "lowPrice": "REAL",
    "percentChange": "REAL",
  };

  static const String TYPE_COIN = "coin";
  static const String TYPE_TOKEN = "token";
  static const String TYPE_FIAT = "fiat";
  static const String TYPE_NFT = "nft";

  Asset({
    @required this.id,
    @required this.name,
    @required this.symbol,
    @required this.value,
    @required this.type,
    this.exchange,
    this.blockchain,
    this.contractAddress,
    this.lastPrice,
    this.highPrice,
    this.lowPrice,
    this.percentChange,
  })  : assert(id != null),
        assert(name != null),
        assert(symbol != null),
        assert(value != null),
        assert(type != null);

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
      type: rawAsset["type"],
      value: value != null ? value.toDouble() : 0.0,
      exchange: rawAsset["exchange"],
      blockchain: rawAsset["blockchain"],
      contractAddress: rawAsset["contractAddress"],
      lastPrice: lastPrice != null ? lastPrice.toDouble() : 0.0,
      highPrice: highPrice != null ? highPrice.toDouble() : 0.0,
      lowPrice: lowPrice != null ? lowPrice.toDouble() : 0.0,
      percentChange: percentChange != null ? percentChange.toDouble() : 0.0,
    );
  }

  static Future<List<Asset>> find({
    Map<String, dynamic> filters,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final List<Asset> assets = new List();

    final List<Map<String, dynamic>> rawAssets = await DatabaseService().find(
      Asset.tableName,
      Asset.tableColumns.keys.toList(),
      filters,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
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
    map["type"] = this.type;
    map["value"] = this.value;
    map["exchange"] = this.exchange;
    map["blockchain"] = this.blockchain;
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
