class CryptoCurrency {
  final String symbol;
  String price;
  final String iconUrl;
  String baseCurrencyPriceInUSD;
  String quoteCurrencyPriceInUSD;

  CryptoCurrency.fromBinanceJson(Map<String, dynamic> json, this.iconUrl,
      this.baseCurrencyPriceInUSD, this.quoteCurrencyPriceInUSD)
      : symbol = json['symbol'],
        price = json['price'];

  CryptoCurrency copyWith({
    String? symbol,
    String? price,
    String? iconUrl,
    String? baseCurrencyPriceInUSD,
    String? quoteCurrencyPriceInUSD,
  }) {
    return CryptoCurrency.fromBinanceJson(
      {
        'symbol': symbol ?? this.symbol,
        'price': price ?? this.price,
      },
      iconUrl ?? this.iconUrl,
      baseCurrencyPriceInUSD ?? this.baseCurrencyPriceInUSD,
      quoteCurrencyPriceInUSD ?? this.quoteCurrencyPriceInUSD,
    );
  }

  @override
  String toString() {
    return 'Symbol: $symbol, Pair Price: $price, Base in USD: $baseCurrencyPriceInUSD, Quote in USD: $quoteCurrencyPriceInUSD';
  }
}
