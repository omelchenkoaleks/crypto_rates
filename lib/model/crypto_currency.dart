class CryptoCurrency {
  final String symbol;
  String price;
  final String iconUrl;

  CryptoCurrency.fromBinanceJson(Map<String, dynamic> json, this.iconUrl)
      : symbol = json['symbol'],
        price = json['price'];
}
