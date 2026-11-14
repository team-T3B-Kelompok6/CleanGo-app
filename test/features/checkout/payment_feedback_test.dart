import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/address/controllers/address_controller.dart';
import 'package:cleango_app/features/address/domain/models/address_model.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:cleango_app/features/checkout/domain/models/payment_method_model.dart';
import 'package:cleango_app/features/checkout/pages/payment_page.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/pages/orders_page.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _BookingApi extends CustomerBookingApi {
  _BookingApi({this.status = 'pending', this.checkoutUrl});

  String status;
  final String? checkoutUrl;
  int createdCount = 0;
  int paidCalls = 0;
  int fetchCalls = 0;

  CreatedBooking get serverBooking => CreatedBooking(
    id: '42',
    code: 'CG-42',
    status: 'Menunggu Assign',
    totalAmount: 155000,
    paymentStatus: status,
  );

  @override
  Future<List<BookingSlotInfo>> availability({
    required String date,
    String? serviceId,
  }) async => [
    for (final time in BookingController.availableTimes)
      BookingSlotInfo(time: time, available: true),
  ];

  @override
  Future<CreatedBooking> create({
    required String serviceId,
    required String date,
    required String time,
    String? addressId,
    String notes = '',
  }) async {
    createdCount++;
    return serverBooking;
  }

  @override
  Future<BookingPayment> pay({
    required String bookingId,
    required String method,
  }) async {
    paidCalls++;
    return BookingPayment(
      booking: serverBooking,
      status: status,
      checkoutUrl: checkoutUrl,
      expiresAt: null,
    );
  }

  @override
  Future<CreatedBooking> fetchBooking(String bookingId) async {
    fetchCalls++;
    return serverBooking;
  }
}

class _FailingDraftBooking extends BookingController {
  _FailingDraftBooking() : super(bookingApi: _BookingApi(status: 'paid'));

  @override
  Future<void> clearDraft() async => throw Exception('Storage unavailable');
}

void main() {
  Future<OrderController> openPayment(
    WidgetTester tester, {
    BookingController? booking,
    PaymentMethodType method = PaymentMethodType.cash,
  }) async {
    const uji = AddressModel(
      id: 'uji-1',
      title: 'Rumah Uji',
      fullAddress: 'Jl. Uji No. 1, Kota Uji',
      type: 'Rumah',
      contactName: 'Pemilik Uji',
      phoneNumber: '081200000001',
    );
    final draft = booking ?? BookingController(bookingApi: _BookingApi());
    draft
      ..startBooking(ServiceData.services.first)
      ..updateAddress(uji.toCleaningAddress(), addressId: uji.id)
      ..selectDate(DateTime.now().add(const Duration(days: 1)));
    await draft.loadAvailability();
    draft.selectTime('10:00');
    final orders = OrderController()..completeScheduledOrder();
    addTearDown(draft.dispose);
    addTearDown(orders.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: draft),
          ChangeNotifierProvider.value(value: orders),
          ChangeNotifierProvider(
            create: (_) => AddressController(initialAddresses: const [uji]),
          ),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => ServiceController()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: PaymentPage(
            method: paymentMethodByType(method),
            totalPayment: 'Rp155.000',
            servicePrice: 150000,
            platformFee: 5000,
            discountAmount: 0,
          ),
        ),
      ),
    );
    return orders;
  }

  testWidgets('cash payment displays on-site instruction card without countdown timer', (
    tester,
  ) async {
    await openPayment(tester, method: PaymentMethodType.cash);
    expect(find.text('Bayar Tunai di Tempat'), findsOneWidget);
    expect(find.textContaining('Siapkan uang pas saat cleaner tiba'), findsOneWidget);
    expect(find.text('Konfirmasi Pembayaran Tunai'), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'cash confirmation shows a notice, navigates directly and ignores repeated submission',
    (tester) async {
      final orders = await openPayment(tester);
      var updates = 0;
      orders.addListener(() => updates++);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Konfirmasi Pembayaran Tunai'),
      );
      button.onPressed!();
      button.onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(updates, 1);
      expect(orders.hasScheduledOrder, isTrue);
      expect(orders.scheduledOrder.paymentStatus, 'Tunai · Bayar di lokasi');
      expect(find.byType(OrdersPage), findsOneWidget);
      expect(find.textContaining('Siapkan pembayaran tunai'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('legacy checkout link fails closed without confirming order', (
    tester,
  ) async {
    final api = _BookingApi(checkoutUrl: 'https://checkout.xendit.co/legacy');
    final orders = await openPayment(
      tester,
      booking: BookingController(bookingApi: api),
      method: PaymentMethodType.qris,
    );
    await tester.tap(find.text('Lanjutkan Pembayaran'));
    await tester.pumpAndSettle();
    expect(orders.hasScheduledOrder, isFalse);
    expect(find.byType(PaymentPage), findsOneWidget);
    expect(
      find.text('Tautan pembayaran tidak valid. Hubungi admin.'),
      findsOneWidget,
    );
    expect(api.createdCount, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('QRIS confirms only after server reports paid', (tester) async {
    final api = _BookingApi();
    final orders = await openPayment(
      tester,
      booking: BookingController(bookingApi: api),
      method: PaymentMethodType.qris,
    );
    var updates = 0;
    orders.addListener(() => updates++);
    await tester.tap(find.text('Lanjutkan Pembayaran'));
    await tester.pumpAndSettle();
    expect(orders.hasScheduledOrder, isFalse);
    expect(updates, 0);
    expect(find.byType(PaymentPage), findsOneWidget);
    expect(find.byType(OrdersPage), findsNothing);
    expect(
      find.text('Pembayaran berhasil. Pesanan Anda sudah dikonfirmasi.'),
      findsNothing,
    );

    await tester.tap(find.text('Cek Status Pembayaran'));
    await tester.pumpAndSettle();
    expect(orders.hasScheduledOrder, isFalse);
    expect(updates, 0);
    expect(find.textContaining('Pembayaran belum diterima.'), findsOneWidget);

    api.status = 'paid';
    await tester.tap(find.text('Cek Status Pembayaran'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(updates, 1);
    expect(orders.hasScheduledOrder, isTrue);
    expect(orders.scheduledOrder.paymentStatus, 'QRIS Terbayar');
    expect(find.byType(OrdersPage), findsOneWidget);
    expect(
      find.text('Pembayaran berhasil. Pesanan Anda sudah dikonfirmasi.'),
      findsOneWidget,
    );
    expect(api.createdCount, 1);
    expect(api.paidCalls, 1);
    expect(api.fetchCalls, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('payment stays readable on narrow screen with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() async {
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await tester.binding.setSurfaceSize(null);
    });
    await openPayment(tester, method: PaymentMethodType.qris);
    final booking = tester
        .element(find.byType(PaymentPage))
        .read<BookingController>();
    const note = 'Tolong bersihkan semua sudut ruangan dan area dekat jendela.';
    booking.updateNote(note);
    await tester.pump();
    expect(find.text('Rp155.000'), findsOneWidget);
    expect(find.text('Lanjutkan Pembayaran'), findsOneWidget);
    expect(find.textContaining('Midtrans'), findsNothing);
    expect(find.textContaining('Sandbox'), findsNothing);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Detail Pesanan'));
    final waitingStyle = tester
        .widget<Text>(find.text('Menunggu pembayaran'))
        .style;
    final detailStyle = tester.widget<Text>(find.text('Detail Pesanan')).style;
    expect(detailStyle, waitingStyle);
    expect(detailStyle?.fontSize, 16);
    expect(detailStyle?.fontWeight, FontWeight.w600);
    final bodyStyle = Theme.of(tester.element(find.byType(PaymentPage)))
        .textTheme
        .bodyMedium!;
    for (final label in ['Layanan', 'Jadwal', 'Alamat', 'Catatan']) {
      expect(
        tester.widget<Text>(find.text(label)).style,
        bodyStyle.copyWith(color: AppColors.slate500),
      );
    }
    for (final value in [
      booking.service!.title,
      '${booking.formattedSelectedDate}, ${booking.formattedSelectedTime}',
      '${booking.address.label}\n${booking.address.fullAddress}',
      note,
    ]) {
      final text = tester.widget<Text>(find.text(value));
      expect(text.style, bodyStyle.copyWith(color: AppColors.slate900));
      expect(text.style?.fontFamily, 'Inter');
      expect(text.style?.fontSize, 14);
      expect(text.style?.fontWeight, FontWeight.w400);
      expect(text.maxLines, isNull);
      expect(text.overflow, isNull);
      expect(text.softWrap, isNot(false));
      await tester.ensureVisible(find.text(value));
      await tester.pump();
      expect(
        tester
            .getRect(find.text(value))
            .overlaps(tester.getRect(find.byType(SingleChildScrollView))),
        isTrue,
      );
    }
    expect(tester.getSize(find.text(note)).height, greaterThan(14 * 2 * 1.45));
    expect(tester.widget<Text>(find.text('Pembayaran')).style?.fontSize, 20);
    expect(tester.widget<Text>(find.text('Rp155.000')).style?.fontSize, 28);
    expect(tester.widget<Text>(find.text('QRIS')).style?.fontSize, 16);
    expect(
      tester.widget<Text>(find.text('Lanjutkan Pembayaran')).style?.fontWeight,
      FontWeight.w600,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('storage failure shows error and does not create an order', (
    tester,
  ) async {
    final orders = await openPayment(
      tester,
      booking: _FailingDraftBooking(),
      method: PaymentMethodType.qris,
    );
    await tester.tap(find.text('Lanjutkan Pembayaran'));
    await tester.pumpAndSettle();
    expect(orders.hasScheduledOrder, isFalse);
    expect(find.byType(PaymentPage), findsOneWidget);
    expect(
      find.text('Pesanan belum berhasil diproses. Silakan coba lagi.'),
      findsOneWidget,
    );
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      AppColors.notification,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Cek Status Pembayaran'),
          )
          .onPressed,
      isNotNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
