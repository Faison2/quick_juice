import 'package:flutter/material.dart';
import '../models/zesa_purchase.dart';
import 'detail_dialog.dart';

Future<MeterMode?> showChooseZesaOptionDialog(BuildContext context) {
  return showAppDialog<MeterMode>(
    context: context,
    title: 'Choose Option',
    child: Column(
      children: [
        OptionRow(
          icon: Icons.bolt,
          label: 'Zesa',
          onTap: () => Navigator.of(context).pop(MeterMode.single),
        ),
        OptionRow(
          icon: Icons.bolt,
          label: 'Zesa & split meter',
          onTap: () => Navigator.of(context).pop(MeterMode.split),
        ),
      ],
    ),
  );
}

enum PinEntryMethod { scan, manual }

Future<PinEntryMethod?> showScanOrManualDialog(BuildContext context, String networkLabel) {
  return showAppDialog<PinEntryMethod>(
    context: context,
    title: networkLabel,
    child: Column(
      children: [
        OptionRow(
          icon: Icons.document_scanner_outlined,
          label: 'Scan Voucher',
          onTap: () => Navigator.of(context).pop(PinEntryMethod.scan),
        ),
        OptionRow(
          icon: Icons.edit_outlined,
          label: 'Enter Manually',
          onTap: () => Navigator.of(context).pop(PinEntryMethod.manual),
        ),
      ],
    ),
  );
}
