import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum Network { econet, netone, telecel }

extension NetworkDetails on Network {
  String get label {
    switch (this) {
      case Network.econet:
        return 'Econet';
      case Network.netone:
        return 'NetOne';
      case Network.telecel:
        return 'Telecel';
    }
  }

  String get ussdPrefix {
    switch (this) {
      case Network.econet:
        return '*121*';
      case Network.netone:
        return '*133*';
      case Network.telecel:
        return '*123*';
    }
  }

  Color get color {
    switch (this) {
      case Network.econet:
        return AppColors.econet;
      case Network.netone:
        return AppColors.netone;
      case Network.telecel:
        return AppColors.telecel;
    }
  }

  Color get colorDark {
    switch (this) {
      case Network.econet:
        return AppColors.econetDark;
      case Network.netone:
        return AppColors.netoneDark;
      case Network.telecel:
        return AppColors.telecelDark;
    }
  }

  IconData get icon {
    switch (this) {
      case Network.econet:
        return Icons.signal_cellular_alt;
      case Network.netone:
        return Icons.cell_tower;
      case Network.telecel:
        return Icons.phone_in_talk;
    }
  }

  String buildUssdCode(String pin) => '$ussdPrefix$pin#';

  String get storageKey => name;

  static Network fromStorageKey(String? key) {
    return Network.values.firstWhere(
      (n) => n.storageKey == key,
      orElse: () => Network.econet,
    );
  }
}
