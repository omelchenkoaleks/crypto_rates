class CryptoCurrency {
  String symbol;
  String price;
  String iconUrl;

  CryptoCurrency({
    required this.symbol,
    required this.price,
    required this.iconUrl,
  });

  factory CryptoCurrency.fromBinanceJson(
      Map<String, dynamic> json, String iconUrl) {
    final symbol = json['symbol'];
    return CryptoCurrency(
      symbol: symbol,
      price: json['price'],
      iconUrl: iconUrl,
    );
  }
}
