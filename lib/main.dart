import "package:flutter/material.dart";

import "package:cryptarch/app.dart";
import "package:cryptarch/services/services.dart" show DatabaseService;

void main() {
  DatabaseService.register();
  runApp(App());
}
