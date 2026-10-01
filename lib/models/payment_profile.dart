class PaymentProfile {
  final String id;
  final String label;
  final String ecocashNumber;

  PaymentProfile({
    required this.id,
    required this.label,
    required this.ecocashNumber,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'ecocashNumber': ecocashNumber,
  };

  factory PaymentProfile.fromJson(Map<String, dynamic> json) {
    return PaymentProfile(
      id: json['id'] as String,
      label: json['label'] as String,
      ecocashNumber: json['ecocashNumber'] as String,
    );
  }
}
