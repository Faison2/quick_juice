import 'network.dart';

enum RechargeStatus { autoDialed, dialerOpened, failed }

class RechargeRecord {
  final String id;
  final Network network;
  final String pin;
  final DateTime dialedAt;
  final RechargeStatus status;

  RechargeRecord({
    required this.id,
    required this.network,
    required this.pin,
    required this.dialedAt,
    required this.status,
  });

  String get maskedPin {
    if (pin.length <= 4) return pin;
    return '•' * (pin.length - 4) + pin.substring(pin.length - 4);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'network': network.storageKey,
    'pin': pin,
    'dialedAt': dialedAt.toIso8601String(),
    'status': status.name,
  };

  factory RechargeRecord.fromJson(Map<String, dynamic> json) {
    return RechargeRecord(
      id: json['id'] as String,
      network: NetworkDetails.fromStorageKey(json['network'] as String?),
      pin: json['pin'] as String,
      dialedAt: DateTime.parse(json['dialedAt'] as String),
      status: RechargeStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => RechargeStatus.failed,
      ),
    );
  }
}
