import 'package:crypto_rates/domain/entity/crypto_currency.dart';
import 'package:crypto_rates/presentation/cubit/crypto_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoListScreen extends StatelessWidget {
  const CryptoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Prices'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search...',
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<CryptoCubit, List<CryptoCurrency>>(
        builder: (context, cryptoList) {
          if (cryptoList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: cryptoList.length,
            itemBuilder: (context, index) {
              final crypto = cryptoList[index];
              return ListTile(
                leading: crypto.iconUrl.isNotEmpty
                    ? Image.network(crypto.iconUrl, width: 40, height: 40)
                    : Container(width: 40, height: 40, color: Colors.grey),
                title: Text(crypto.symbol),
                subtitle: Text('Price: ${crypto.price}'),
              );
            },
          );
        },
      ),
    );
  }
}
