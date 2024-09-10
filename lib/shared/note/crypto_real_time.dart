// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class CryptoCurrency {
//   final String symbol;
//   final String price;

//   CryptoCurrency({required this.symbol, required this.price});

//   factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
//     return CryptoCurrency(
//       symbol: json['s'] ?? 'Unknown',
//       price: json['c'] ?? '0.0',
//     );
//   }
// }

// class CryptoRealTimeScreen extends StatefulWidget {
//   const CryptoRealTimeScreen({super.key});

//   @override
//   State<CryptoRealTimeScreen> createState() => _CryptoRealTimeScreenState();
// }

// class _CryptoRealTimeScreenState extends State<CryptoRealTimeScreen> {
//   final WebSocketChannel channel = WebSocketChannel.connect(
//     Uri.parse('wss://stream.binance.com:9443/ws/!ticker@arr'),
//   );
//   List<CryptoCurrency> _cryptoList = [];

//   @override
//   void initState() {
//     super.initState();
//     channel.stream.listen((data) {
//       final List<dynamic> jsonData = json.decode(data);

//       setState(() {
//         _cryptoList =
//             jsonData.map((json) => CryptoCurrency.fromJson(json)).toList();

//         _cryptoList.sort((a, b) => a.symbol.compareTo(b.symbol));
//       });
//     });
//   }

//   @override
//   void dispose() {
//     channel.sink.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Crypto Prices (Real Time)'),
//       ),
//       body: _cryptoList.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _cryptoList.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_cryptoList[index].symbol),
//                   subtitle: Text('Price: ${_cryptoList[index].price}'),
//                 );
//               },
//             ),
//     );
//   }
// }

// void main() {
//   runApp(const MaterialApp(home: CryptoRealTimeScreen()));
// }
