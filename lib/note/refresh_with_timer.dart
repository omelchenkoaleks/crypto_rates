// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class CryptoCurrency {
//   final String symbol;
//   String price;

//   CryptoCurrency({required this.symbol, required this.price});

//   factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
//     return CryptoCurrency(
//       symbol: json['symbol'],
//       price: json['price'],
//     );
//   }
// }

// class CryptoListScreen extends StatefulWidget {
//   const CryptoListScreen({super.key});

//   @override
//   State<CryptoListScreen> createState() => _CryptoListScreenState();
// }

// class _CryptoListScreenState extends State<CryptoListScreen> {
//   final List<CryptoCurrency> _cryptoList = [];
//   bool _isLoading = false;
//   bool _isRefreshing = false;
//   int _currentPage = 0;
//   final int _perPage = 20;
//   final ScrollController _scrollController = ScrollController();
//   Timer? _refreshTimer;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCryptoData();
//     _scrollController.addListener(_onScroll);
//     _startPeriodicRefresh();
//   }

//   Future<void> _fetchCryptoData() async {
//     if (_isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http
//           .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);

//         setState(() {
//           List<CryptoCurrency> newItems = data
//               .skip(_currentPage * _perPage)
//               .take(_perPage)
//               .map((json) => CryptoCurrency.fromJson(json))
//               .toList();

//           if (newItems.isEmpty) {
//             _isLoading = false;
//           } else {
//             _cryptoList.addAll(newItems);
//             _cryptoList.sort((a, b) => a.symbol.compareTo(b.symbol));
//             _currentPage++;
//           }
//         });
//       } else {
//         throw Exception('Failed to load crypto data');
//       }
//     } catch (e) {
//       print("Ошибка загрузки данных: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       _fetchCryptoData();
//     }
//   }

//   Future<void> _refreshCryptoData() async {
//     setState(() {
//       _isRefreshing = true;
//     });

//     try {
//       final response = await http
//           .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);

//         setState(() {
//           final newItems =
//               data.map((json) => CryptoCurrency.fromJson(json)).toList();
//           final Map<String, String> newPrices = {
//             for (var item in newItems) item.symbol: item.price
//           };

//           for (var crypto in _cryptoList) {
//             if (newPrices.containsKey(crypto.symbol)) {
//               crypto.price = newPrices[crypto.symbol]!;
//             }
//           }
//         });
//       } else {
//         throw Exception('Failed to load crypto data');
//       }
//     } catch (e) {
//       print("Ошибка обновления данных: $e");
//     } finally {
//       setState(() {
//         _isRefreshing = false;
//       });
//     }
//   }

//   void _startPeriodicRefresh() {
//     _refreshTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
//       _refreshCryptoData();
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _refreshTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Crypto Prices'),
//       ),
//       body: Stack(
//         children: [
//           _cryptoList.isEmpty && !_isLoading
//               ? const Center(child: Text('No data available'))
//               : ListView.builder(
//                   controller: _scrollController,
//                   itemCount: _cryptoList.length + (_isLoading ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index == _cryptoList.length) {
//                       return Container();
//                     }
//                     return ListTile(
//                       title: Text(_cryptoList[index].symbol),
//                       subtitle: Text('Price: ${_cryptoList[index].price}'),
//                     );
//                   },
//                 ),
//           if (_isLoading || _isRefreshing)
//             const Align(
//               alignment: Alignment.center,
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }

// void main() {
//   runApp(const MaterialApp(home: CryptoListScreen()));
// }