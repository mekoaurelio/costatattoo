// To parse this JSON data, do
//
//     final bitGet = bitGetFromJson(jsonString);

import 'dart:convert';

BitGet bitGetFromJson(String str) => BitGet.fromJson(json.decode(str));

String bitGetToJson(BitGet data) => json.encode(data.toJson());

class BitGet {
  String code;
  List<Datum> data;
  String msg;
  int requestTime;

  BitGet({
    required this.code,
    required this.data,
    required this.msg,
    required this.requestTime,
  });

  factory BitGet.fromJson(Map<String, dynamic> json) => BitGet(
    code: json["code"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    msg: json["msg"],
    requestTime: json["requestTime"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "msg": msg,
    "requestTime": requestTime,
  };
}

class Datum {
  String baseCoin;
  String buyLimitPriceRatio;
  String feeRateUpRatio;
  String makerFeeRate;
  String minTradeNum;
  String openCostUpRatio;
  String priceEndStep;
  String pricePlace;
  String quoteCoin;
  String sellLimitPriceRatio;
  String sizeMultiplier;
  List<String> supportMarginCoins;
  String symbol;
  String takerFeeRate;
  String volumePlace;
  String symbolType;
  String symbolStatus;
  String offTime;
  String limitOpenTime;

  Datum({
    required this.baseCoin,
    required this.buyLimitPriceRatio,
    required this.feeRateUpRatio,
    required this.makerFeeRate,
    required this.minTradeNum,
    required this.openCostUpRatio,
    required this.priceEndStep,
    required this.pricePlace,
    required this.quoteCoin,
    required this.sellLimitPriceRatio,
    required this.sizeMultiplier,
    required this.supportMarginCoins,
    required this.symbol,
    required this.takerFeeRate,
    required this.volumePlace,
    required this.symbolType,
    required this.symbolStatus,
    required this.offTime,
    required this.limitOpenTime,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    baseCoin: json["baseCoin"],
    buyLimitPriceRatio: json["buyLimitPriceRatio"],
    feeRateUpRatio: json["feeRateUpRatio"],
    makerFeeRate: json["makerFeeRate"],
    minTradeNum: json["minTradeNum"],
    openCostUpRatio: json["openCostUpRatio"],
    priceEndStep: json["priceEndStep"],
    pricePlace: json["pricePlace"],
    quoteCoin: json["quoteCoin"],
    sellLimitPriceRatio: json["sellLimitPriceRatio"],
    sizeMultiplier: json["sizeMultiplier"],
    supportMarginCoins: List<String>.from(json["supportMarginCoins"].map((x) => x)),
    symbol: json["symbol"],
    takerFeeRate: json["takerFeeRate"],
    volumePlace: json["volumePlace"],
    symbolType: json["symbolType"],
    symbolStatus: json["symbolStatus"],
    offTime: json["offTime"],
    limitOpenTime: json["limitOpenTime"],
  );

  Map<String, dynamic> toJson() => {
    "baseCoin": baseCoin,
    "buyLimitPriceRatio": buyLimitPriceRatio,
    "feeRateUpRatio": feeRateUpRatio,
    "makerFeeRate": makerFeeRate,
    "minTradeNum": minTradeNum,
    "openCostUpRatio": openCostUpRatio,
    "priceEndStep": priceEndStep,
    "pricePlace": pricePlace,
    "quoteCoin": quoteCoin,
    "sellLimitPriceRatio": sellLimitPriceRatio,
    "sizeMultiplier": sizeMultiplier,
    "supportMarginCoins": List<dynamic>.from(supportMarginCoins.map((x) => x)),
    "symbol": symbol,
    "takerFeeRate": takerFeeRate,
    "volumePlace": volumePlace,
    "symbolType": symbolType,
    "symbolStatus": symbolStatus,
    "offTime": offTime,
    "limitOpenTime": limitOpenTime,
  };
}
