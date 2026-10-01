import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

enum DialOutcome { autoDialed, dialerOpened, unsupported, failed }

class UssdService {
  static const MethodChannel _channel = MethodChannel('jucie_up/ussd');

  Future<DialOutcome> dial(String ussdCode) async {
    if (!Platform.isAndroid) {
      return DialOutcome.unsupported;
    }

    final status = await Permission.phone.request();
    if (status.isGranted) {
      try {
        final ok = await _channel.invokeMethod<bool>('dialUssd', {
          'code': ussdCode,
        });
        if (ok == true) return DialOutcome.autoDialed;
      } on PlatformException {
        // fall through to dialer fallback
      }
    }

    return _openDialer(ussdCode);
  }

  Future<DialOutcome> _openDialer(String ussdCode) async {
    final uri = Uri(scheme: 'tel', path: ussdCode);
    try {
      final launched = await launchUrl(uri);
      return launched ? DialOutcome.dialerOpened : DialOutcome.failed;
    } catch (_) {
      return DialOutcome.failed;
    }
  }
}
