import 'dart:io';

import 'package:cleango_app/core/database/app_database.dart';
import 'package:cleango_app/features/booking/data/booking_draft_repository.dart';
import 'package:cleango_app/features/booking/domain/models/booking_draft.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('draft booking tetap tersedia setelah database dibuka ulang', () async {
    final directory = await Directory.systemTemp.createTemp('cleango-draft-');
    final file = File('${directory.path}/test.sqlite');
    final firstDatabase = AppDatabase(NativeDatabase(file));
    final repository = BookingDraftRepository(firstDatabase);
    final updatedAt = DateTime.utc(2030, 1, 2, 3);

    await repository.saveDraft(
      BookingDraft(
        serviceId: 'deep-cleaning',
        selectedDate: DateTime(2030, 1, 10),
        selectedTime: '16:00',
        addressId: 'addr-1',
        note: 'Fokus dapur',
        updatedAt: updatedAt,
      ),
    );
    await firstDatabase.close();

    final reopenedDatabase = AppDatabase(NativeDatabase(file));
    final reopened = BookingDraftRepository(reopenedDatabase);
    final draft = await reopened.readDraft();

    expect(draft?.serviceId, 'deep-cleaning');
    expect(draft?.selectedTime, '16:00');
    expect(draft?.addressId, 'addr-1');
    expect(draft?.note, 'Fokus dapur');

    await reopenedDatabase.close();
    await directory.delete(recursive: true);
  });
}
