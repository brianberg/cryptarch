class Settings {
  String currency = "USD";
  bool showMining = false;

  Settings({
    this.currency,
    this.showMining,
  });

  factory Settings.fromMap(Map<String, dynamic> rawSettings) {
    return Settings(
      currency: rawSettings["currency"],
      showMining: rawSettings["showMining"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "currency": this.currency,
      "showMining": this.showMining ?? false,
    };
  }
}
