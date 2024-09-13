import 'package:crypto_rates/feature/crypto_list/cubit/crypto_list_cubit.dart';
import 'package:crypto_rates/feature/crypto_list/cubit/crypto_list_state.dart';
import 'package:crypto_rates/feature/crypto_list/model/crypto_currency.dart';
import 'package:crypto_rates/utility/formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoPairDetailScreen extends StatelessWidget {
  final CryptoCurrency crypto;

  const CryptoPairDetailScreen({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency pair: ${Formatting.formatSymbol(crypto.symbol)}'),
      ),
      body: BlocBuilder<CryptoListCubit, CryptoListState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 36,
              top: 24,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Formatting.formatSymbol(crypto.symbol)} price: ${crypto.price}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Base currency: ${crypto.baseCurrencyPriceInUSD.toUpperCase()} dollar price: ${state.baseCurrencyPrice}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Quote currency ${crypto.quoteCurrencyPriceInUSD.toUpperCase()} dollar price: ${state.quoteCurrencyPrice}',
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
