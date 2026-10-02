import 'package:flutter/material.dart';
import 'detail_dialog.dart';

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
