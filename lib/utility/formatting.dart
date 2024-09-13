class Formatting {
  static String formatSymbol(String symbol) {
    if (symbol.endsWith('USDT')) {
      return '${symbol.substring(0, symbol.length - 4)} USDT';
    }

    if (symbol.endsWith('TUSD')) {
      return '${symbol.substring(0, symbol.length - 4)} TUSD';
    }

    if (symbol.endsWith('BUSD')) {
      return '${symbol.substring(0, symbol.length - 4)} BUSD';
    }

    if (symbol.endsWith('USDC')) {
      return '${symbol.substring(0, symbol.length - 4)} USDC';
    }

    final pattern = RegExp(r'([A-Z]+)([A-Z]{3})$');
    final match = pattern.firstMatch(symbol);

    if (match != null) {
      final baseCurrency = match.group(1);
      final quoteCurrency = match.group(2);
      return '$baseCurrency $quoteCurrency';
    }

    return symbol;
  }
}
