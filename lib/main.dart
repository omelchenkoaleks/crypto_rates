import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CryptoCurrency {
  final String symbol;
  final String price;

  CryptoCurrency({required this.symbol, required this.price});

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    return CryptoCurrency(
      symbol: json['s'], // символ
      price: json['c'], // текущая цена
    );
  }
}

class CryptoRealTimeScreen extends StatefulWidget {
  const CryptoRealTimeScreen({super.key});

  @override
  State<CryptoRealTimeScreen> createState() => _CryptoRealTimeScreenState();
}

class _CryptoRealTimeScreenState extends State<CryptoRealTimeScreen> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://stream.binance.com:9443/ws/!ticker@arr'),
  );
  List<CryptoCurrency> _cryptoList = [];

  @override
  void initState() {
    super.initState();
    // Подписываемся на WebSocket
    channel.stream.listen((data) {
      final List<dynamic> jsonData = json.decode(data);

      setState(() {
        _cryptoList =
            jsonData.map((json) => CryptoCurrency.fromJson(json)).toList();
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close(); // Закрываем WebSocket соединение
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Prices (Real Time)'),
      ),
      body: _cryptoList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _cryptoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_cryptoList[index].symbol),
                  subtitle: Text('Price: ${_cryptoList[index].price}'),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: CryptoRealTimeScreen()));
}




// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class CryptoCurrency {
//   final String symbol;
//   final String price;

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
//   List<CryptoCurrency> _cryptoList = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchCryptoData();
//   }

//   Future<void> _fetchCryptoData() async {
//     final response = await http
//         .get(Uri.parse('https://api.binance.com/api/v3/ticker/price'));

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       setState(() {
//         _cryptoList =
//             data.map((json) => CryptoCurrency.fromJson(json)).toList();
//       });
//     } else {
//       throw Exception('Failed to load crypto data');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Crypto Prices'),
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
//   runApp(const MaterialApp(home: CryptoListScreen()));
// }
