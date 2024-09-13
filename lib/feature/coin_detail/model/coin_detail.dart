class CoinDetail {
  final String symbol;
  final String logoUrl;
  final String fullName;
  final String averagePrice;
  final String binancePrice;

  CoinDetail({
    required this.symbol,
    required this.logoUrl,
    required this.fullName,
    required this.averagePrice,
    required this.binancePrice,
  });

  factory CoinDetail.fromMap(Map<String, dynamic> data) {
    return CoinDetail(
      symbol: data['symbol'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      fullName: data['fullName'] ?? '',
      averagePrice: data['averagePrice'] ?? '',
      binancePrice: data['price'] ?? '',
    );
  }

  factory CoinDetail.empty() {
    return CoinDetail(
      symbol: '',
      logoUrl: '',
      fullName: '',
      averagePrice: '',
      binancePrice: '',
    );
  }
}
