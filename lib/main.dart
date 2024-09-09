import 'dart:async';
import 'dart:convert';

import 'package:crypto_rates/utility/logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CryptoCurrency {
  final String symbol;
  String price;

  CryptoCurrency({required this.symbol, required this.price});

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    return CryptoCurrency(
      symbol: json['symbol'],
      price: json['price'],
    );
  }
}

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({super.key});

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  final List<CryptoCurrency> _cryptoList = [];
  List<CryptoCurrency> _filteredCryptoList = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  int _currentPage = 0;
  final int _perPage = 20;
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCryptoData();
    _scrollController.addListener(_onScroll);
    _startPeriodicRefresh();
    _searchController.addListener(_filterCryptoList);
  }

  Future<void> _fetchCryptoData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          List<CryptoCurrency> newItems = data
              .skip(_currentPage * _perPage)
              .take(_perPage)
              .map((json) => CryptoCurrency.fromJson(json))
              .toList();

          if (newItems.isEmpty) {
            _isLoading = false;
          } else {
            _cryptoList.addAll(newItems);
            _cryptoList.sort((a, b) => a.symbol.compareTo(b.symbol));
            _currentPage++;
            _filterCryptoList();
          }
        });
      } else {
        throw Exception('Failed to load crypto data');
      }
    } catch (e) {
      logger.e("Ошибка загрузки данных: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchCryptoData();
    }
  }

  Future<void> _refreshCryptoData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          final newItems =
              data.map((json) => CryptoCurrency.fromJson(json)).toList();
          final Map<String, String> newPrices = {
            for (var item in newItems) item.symbol: item.price
          };

          for (var crypto in _cryptoList) {
            if (newPrices.containsKey(crypto.symbol)) {
              crypto.price = newPrices[crypto.symbol]!;
            }
          }
          _filterCryptoList();
        });
      } else {
        throw Exception('Failed to load crypto data');
      }
    } catch (e) {
      logger.e("Ошибка обновления данных: $e");
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      _refreshCryptoData();
    });
  }

  void _filterCryptoList() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCryptoList = _cryptoList
          .where((crypto) => crypto.symbol.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Prices'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search...',
              ),
              onChanged: (_) => _filterCryptoList(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _filteredCryptoList.isEmpty && !_isLoading
              ? const Center(child: Text('No data available'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _filteredCryptoList.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _filteredCryptoList.length) {
                      return Container();
                    }
                    return ListTile(
                      title: Text(_filteredCryptoList[index].symbol),
                      subtitle:
                          Text('Price: ${_filteredCryptoList[index].price}'),
                    );
                  },
                ),
          if (_isLoading || _isRefreshing)
            const Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: CryptoListScreen()));
}
