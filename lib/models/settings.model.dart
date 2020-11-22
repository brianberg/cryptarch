class Settings {
  String currency;
  bool showMining;

  Settings({
    this.currency,
    this.showMining,
  }) {
    this.currency = this.currency ?? "USD";
    this.showMining = this.showMining ?? false;
  }

  factory Settings.fromMap(Map<String, dynamic> rawSettings) {
    return Settings(
      currency: rawSettings["currency"],
      showMining: rawSettings["showMining"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "currency": this.currency,
      "showMining": this.showMining,
    };
  }
}
