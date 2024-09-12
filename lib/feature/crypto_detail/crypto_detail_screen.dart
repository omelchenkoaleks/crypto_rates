import 'package:crypto_rates/feature/crypto_list/cubit/crypto_list_cubit.dart';
import 'package:crypto_rates/feature/crypto_list/cubit/crypto_list_state.dart';
import 'package:crypto_rates/model/crypto_currency.dart';
import 'package:crypto_rates/utility/formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoDetailScreen extends StatelessWidget {
  final CryptoCurrency crypto;

  const CryptoDetailScreen({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Formatting.formatSymbol(crypto.symbol)),
      ),
      body: BlocBuilder<CryptoListCubit, CryptoListState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pair: ${Formatting.formatSymbol(crypto.symbol)}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  'Price: ${crypto.price}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'base ${crypto.baseCurrencyPriceInUSD}: ${state.baseCurrencyPrice}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'quote ${crypto.quoteCurrencyPriceInUSD}: ${state.quoteCurrencyPrice}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
