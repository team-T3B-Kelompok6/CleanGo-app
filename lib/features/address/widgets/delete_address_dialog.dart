import 'package:flutter/material.dart';

import '../../../shared/widgets/app_dialog.dart';

class DeleteAddressDialog extends StatelessWidget {
  const DeleteAddressDialog({
    super.key,
    required this.addressLabel,
    required this.onConfirm,
  });

  final String addressLabel;
  final VoidCallback onConfirm;

  static Future<bool?> show(
    BuildContext context, {
    required String addressLabel,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => DeleteAddressDialog(
        addressLabel: addressLabel,
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          onConfirm();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Hapus alamat?',
      message:
          'Alamat "$addressLabel" akan dihapus dari daftar tersimpan dan tidak dapat dipulihkan.',
      confirmLabel: 'Hapus Alamat',
      onConfirm: onConfirm,
      cancelLabel: 'Batal',
      isDestructive: true,
    );
  }
}
