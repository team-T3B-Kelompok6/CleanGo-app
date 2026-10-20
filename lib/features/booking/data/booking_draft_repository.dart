import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/models/booking_draft.dart';

class BookingDraftRepository {
  BookingDraftRepository(this._database);

  static const activeDraftId = 'active-booking';

  final AppDatabase _database;

  Stream<BookingDraft?> watchDraft() {
    return _database.watchBookingDraft(activeDraftId).map(_fromRow);
  }

  Future<BookingDraft?> readDraft() async {
    return _fromRow(await _database.readBookingDraft(activeDraftId));
  }

  Future<void> saveDraft(BookingDraft draft) {
    return _database.saveBookingDraft(
      BookingDraftsCompanion.insert(
        id: activeDraftId,
        serviceId: draft.serviceId,
        selectedDate: draft.selectedDate.toUtc().millisecondsSinceEpoch,
        selectedTime: draft.selectedTime,
        addressId: Value(draft.addressId),
        note: Value(draft.note),
        synced: Value(draft.synced),
        updatedAt: draft.updatedAt.toUtc().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> clearDraft() {
    return _database.deleteBookingDraft(activeDraftId);
  }

  BookingDraft? _fromRow(BookingDraftRow? row) {
    if (row == null) return null;
    return BookingDraft(
      serviceId: row.serviceId,
      selectedDate: DateTime.fromMillisecondsSinceEpoch(
        row.selectedDate,
        isUtc: true,
      ).toLocal(),
      selectedTime: row.selectedTime,
      addressId: row.addressId,
      note: row.note,
      synced: row.synced,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
    );
  }
}
