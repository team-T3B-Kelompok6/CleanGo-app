import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class FacebookAccount {
  const FacebookAccount({required this.name, required this.email});
  final String name;
  final String email;
}

const List<FacebookAccount> dummyFacebookAccounts = [
  FacebookAccount(name: 'Budi Santoso', email: 'budi.santoso@facebook.com'),
  FacebookAccount(name: 'Siti Rahma', email: 'siti.rahma@facebook.com'),
];

Future<FacebookAccount?> showFacebookDummyDialog(BuildContext context) {
  return showModalBottomSheet<FacebookAccount>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1877F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'f',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masuk dengan Facebook',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      Text(
                        'Mode simulasi prototype (dummy)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih akun simulasi:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 8),
            ...dummyFacebookAccounts.map((account) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryAction.withValues(alpha: 0.1),
                  child: Text(
                    account.name[0],
                    style: const TextStyle(
                      color: AppColors.primaryAction,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  account.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(account.email),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context, account),
              );
            }),
          ],
        ),
      );
    },
  );
}
