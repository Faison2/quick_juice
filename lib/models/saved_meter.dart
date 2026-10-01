class SavedMeter {
  final String id;
  final String label;
  final String meterNumber;
  final bool isSplit;
  final String? splitMeterNumber;

  SavedMeter({
    required this.id,
    required this.label,
    required this.meterNumber,
    this.isSplit = false,
    this.splitMeterNumber,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'meterNumber': meterNumber,
    'isSplit': isSplit,
    'splitMeterNumber': splitMeterNumber,
  };

  factory SavedMeter.fromJson(Map<String, dynamic> json) {
    return SavedMeter(
      id: json['id'] as String,
      label: json['label'] as String,
      meterNumber: json['meterNumber'] as String,
      isSplit: json['isSplit'] as bool? ?? false,
      splitMeterNumber: json['splitMeterNumber'] as String?,
    );
  }
}
