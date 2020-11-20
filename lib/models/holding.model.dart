import "package:meta/meta.dart";

import "package:sqflite/sqflite.dart";

import "package:cryptarch/services/services.dart" show DatabaseService;

class Holding {
  final String id;
  final String name;
  final String currency;
  double amount;
  String location;
  String address;

  static final String tableName = "holdings";

  static final Map<String, String> tableColumns = {
    "id": "TEXT PRIMARY KEY",
    "name": "TEXT",
    "currency": "TEXT",
    "amount": "REAL",
    "location": "TEXT",
    "address": "TEXT",
  };

  Holding({
    @required this.id,
    @required this.name,
    @required this.currency,
    @required this.amount,
    @required this.location,
    this.address,
  })  : assert(id != null),
        assert(name != null),
        assert(currency != null),
        assert(amount != null),
        assert(location != null);

  static Future<Holding> deserialize(Map<String, dynamic> rawHolding) async {
    final amount = rawHolding["amount"];
    return Holding(
      id: rawHolding["id"],
      name: rawHolding["name"],
      currency: rawHolding["currency"],
      amount: amount != null ? amount.toDouble() : null,
      location: rawHolding["location"],
      address: rawHolding["address"],
    );
  }

  static Future<List<Holding>> find({Map<String, dynamic> filters}) async {
    final List<Holding> assets = new List();

    final List<Map<String, dynamic>> rawHoldings = await DatabaseService().find(
      Holding.tableName,
      Holding.tableColumns.keys.toList(),
      filters,
    );

    for (Map<String, dynamic> rawHolding in rawHoldings) {
      Holding asset = await Holding.deserialize(rawHolding);
      assets.add(asset);
    }

    return assets;
  }

  static Future<Holding> findOneById(String id) async {
    final db = await DatabaseService().connect();
    final rawHoldings = await db.query(
      Holding.tableName,
      columns: Holding.tableColumns.keys.toList(),
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (rawHoldings.isNotEmpty) {
      return Holding.deserialize(rawHoldings.first);
    }

    return null;
  }

  Map<String, dynamic> serialize() {
    final map = new Map<String, dynamic>();
    map["id"] = this.id;
    map["name"] = this.name;
    map["currency"] = this.currency;
    map["amount"] = this.amount;
    map["location"] = this.location;
    map["address"] = this.address;

    return map;
  }

  Future<void> save() async {
    final db = await DatabaseService().connect();
    await db.insert(
      Holding.tableName,
      this.serialize(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    Map<String, dynamic> filters = {};
    filters["id"] = this.id;
    await DatabaseService().delete(Holding.tableName, filters);
  }

  @override
  String toString() => "$currency";
}
