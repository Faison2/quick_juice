enum MeterMode { single, split }

enum ZesaCurrency { usd, zwg }

extension ZesaCurrencyLabel on ZesaCurrency {
  String get label => this == ZesaCurrency.usd ? 'USD' : 'ZWG';
}

class ZesaPurchase {
  final String id;
  final MeterMode mode;
  final String meterNumber;
  final String? splitMeterNumber;
  final String ecocashNumber;
  final String amount;
  final ZesaCurrency currency;
  final DateTime purchasedAt;

  // Optional receipt details the user can paste in after completing the
  // purchase, copied from the EcoCash SMS confirmation. There is no backend
  // to fetch these automatically.
  final String? token;
  final String? splitMeterToken;
  final String? kwh;
  final String? energy;
  final String? debt;
  final String? rea;
  final String? vat;
  final String? totalAmt;
  final String? tendered;

  ZesaPurchase({
    required this.id,
    required this.mode,
    required this.meterNumber,
    this.splitMeterNumber,
    required this.ecocashNumber,
    required this.amount,
    this.currency = ZesaCurrency.usd,
    required this.purchasedAt,
    this.token,
    this.splitMeterToken,
    this.kwh,
    this.energy,
    this.debt,
    this.rea,
    this.vat,
    this.totalAmt,
    this.tendered,
  });

  String get dialMeterNumber =>
      mode == MeterMode.split && splitMeterNumber != null
          ? splitMeterNumber!
          : meterNumber;

  bool get hasReceiptDetails =>
      token != null ||
      kwh != null ||
      energy != null ||
      debt != null ||
      rea != null ||
      vat != null ||
      totalAmt != null ||
      tendered != null;

  ZesaPurchase copyWithReceipt({
    String? token,
    String? splitMeterToken,
    String? kwh,
    String? energy,
    String? debt,
    String? rea,
    String? vat,
    String? totalAmt,
    String? tendered,
  }) {
    return ZesaPurchase(
      id: id,
      mode: mode,
      meterNumber: meterNumber,
      splitMeterNumber: splitMeterNumber,
      ecocashNumber: ecocashNumber,
      amount: amount,
      currency: currency,
      purchasedAt: purchasedAt,
      token: token ?? this.token,
      splitMeterToken: splitMeterToken ?? this.splitMeterToken,
      kwh: kwh ?? this.kwh,
      energy: energy ?? this.energy,
      debt: debt ?? this.debt,
      rea: rea ?? this.rea,
      vat: vat ?? this.vat,
      totalAmt: totalAmt ?? this.totalAmt,
      tendered: tendered ?? this.tendered,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mode': mode.name,
    'meterNumber': meterNumber,
    'splitMeterNumber': splitMeterNumber,
    'ecocashNumber': ecocashNumber,
    'amount': amount,
    'currency': currency.name,
    'purchasedAt': purchasedAt.toIso8601String(),
    'token': token,
    'splitMeterToken': splitMeterToken,
    'kwh': kwh,
    'energy': energy,
    'debt': debt,
    'rea': rea,
    'vat': vat,
    'totalAmt': totalAmt,
    'tendered': tendered,
  };

  factory ZesaPurchase.fromJson(Map<String, dynamic> json) {
    return ZesaPurchase(
      id: json['id'] as String,
      mode: MeterMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => MeterMode.single,
      ),
      meterNumber: json['meterNumber'] as String,
      splitMeterNumber: json['splitMeterNumber'] as String?,
      ecocashNumber: json['ecocashNumber'] as String,
      amount: json['amount'] as String,
      currency: ZesaCurrency.values.firstWhere(
        (c) => c.name == json['currency'],
        orElse: () => ZesaCurrency.usd,
      ),
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      token: json['token'] as String?,
      splitMeterToken: json['splitMeterToken'] as String?,
      kwh: json['kwh'] as String?,
      energy: json['energy'] as String?,
      debt: json['debt'] as String?,
      rea: json['rea'] as String?,
      vat: json['vat'] as String?,
      totalAmt: json['totalAmt'] as String?,
      tendered: json['tendered'] as String?,
    );
  }
}
