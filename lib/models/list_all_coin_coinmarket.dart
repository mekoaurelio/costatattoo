import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CoinMarket {
  static Future<void> loadCryptoList() async {
    final apiKey = '9692be72-b332-4378-b519-cc41a287daeb';
    final url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest';
  //  final url = 'https://pro-api.coinmarketcap.com/v2/cryptocurrency/info';
    final response = await http.get(Uri.parse(url), headers: {
      'X-CMC_PRO_API_KEY': apiKey,
    });

    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final cryptoList = data['data'];

     // Database db = await DatabaseHelper.instance.database;
      //db.delete('allCoins');

      ///Grava todas as moedas em tabela local
      for (int i = 0; i < cryptoList.length; i++) {
        final crypto = cryptoList[i];
        Map<String, dynamic> row = {
          "idCoin": crypto['id'],
          "nome": crypto['name'],
          "symbol": crypto['symbol'],
          "logo": '',
        };
     //   await DatabaseHelper.instance.insert(row,'allCoins');
      }
    } else {
      throw Exception('Falha ao carregar os dados da API');
    }
  }
}