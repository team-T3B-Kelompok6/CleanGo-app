import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../domain/models/booking_draft.dart';

/// Server booking id + the exact draft key it was created for, so a restart
/// resumes the same booking instead of creating a duplicate.
class ServerBookingDraft {
  const ServerBookingDraft({required this.id, required this.key});
  final String id;
  final String key;
}

class BookingDraftRepository {
  BookingDraftRepository(this._database);

  static const activeDraftId = 'active-booking';

  final AppDatabase _database;
  static const _serverBookingIdKey = 'cleango_active_booking_server_id';
  static const _serverBookingKeyKey = 'cleango_active_booking_server_key';

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

  Future<ServerBookingDraft?> readServerBooking() async {
    try {
      final prefs = SharedPreferencesAsync();
      final id = (await prefs.getString(_serverBookingIdKey))?.trim() ?? '';
      if (id.isEmpty) return null;
      return ServerBookingDraft(
        id: id,
        key: (await prefs.getString(_serverBookingKeyKey)) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveServerBooking(ServerBookingDraft draft) async {
    try {
      final prefs = SharedPreferencesAsync();
      await prefs.setString(_serverBookingIdKey, draft.id);
      await prefs.setString(_serverBookingKeyKey, draft.key);
    } catch (_) {}
  }

  Future<void> clearServerBooking() async {
    try {
      final prefs = SharedPreferencesAsync();
      await prefs.remove(_serverBookingIdKey);
      await prefs.remove(_serverBookingKeyKey);
    } catch (_) {}
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
