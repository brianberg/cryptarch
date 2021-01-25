import "dart:convert";

import "package:http/http.dart" as http;
import "package:meta/meta.dart";

import "package:crypto/crypto.dart";
import "package:uuid/uuid.dart";

const NICEHASH_API_URL = "https://api2.nicehash.com";

class NiceHashProvider {
  final organizationId;
  final key;
  final secret;

  NiceHashProvider({
    @required this.organizationId,
    @required this.key,
    @required this.secret,
  })  : assert(organizationId != null),
        assert(key != null),
        assert(secret != null);

  Future<http.Response> getAccounts() {
    String path = "/main/api/v2/accounting/accounts2";
    return http.get(
      "$NICEHASH_API_URL$path",
      headers: this._buildHeaders("GET", path),
    );
  }

  Future<http.Response> getMiningRigs() {
    String path = "/main/api/v2/mining/rigs2";
    return http.get(
      "$NICEHASH_API_URL$path",
      headers: this._buildHeaders("GET", path),
    );
  }

  Future<http.Response> getMiningRig(String rigId) {
    String path = "/main/api/v2/mining/rig2/$rigId";
    return http.get(
      "$NICEHASH_API_URL$path",
      headers: this._buildHeaders("GET", path),
    );
  }

  Future<http.Response> getRigPayouts({
    int pageSize = 84,
    // int page, this doesn"t seem to work, use `afterMillis`
    int afterMillis,
  }) {
    String path = "/main/api/v2/mining/rigs/payouts";
    String query = "size=$pageSize";
    // if (page != null && page > 0) {
    //   query += "&page=$page";
    // }
    if (afterMillis != null) {
      query += "&afterTimestamp=$afterMillis";
    }
    return http.get(
      "$NICEHASH_API_URL$path?$query",
      headers: this._buildHeaders("GET", path, query: query),
    );
  }

  Map<String, String> _buildHeaders(
    String method,
    String path, {
    String query = "",
  }) {
    final uuid = Uuid();
    final xtime = DateTime.now().millisecondsSinceEpoch;
    final xnonce = uuid.v4();
    final message =
        "${this.key}\x00$xtime\x00$xnonce\x00\x00${this.organizationId}\x00\x00$method\x00$path\x00$query";
    final digest =
        Hmac(sha256, utf8.encode(this.secret)).convert(utf8.encode(message));
    final xauth = "${this.key}:$digest";

    Map<String, String> headers = {};
    headers["X-Time"] = xtime.toString();
    headers["X-Nonce"] = xnonce;
    headers["X-Auth"] = xauth;
    headers["Content-Type"] = "application/json";
    headers["X-Organization-Id"] = this.organizationId;
    headers["X-Request-Id"] = uuid.v4();

    return headers;
  }
}
