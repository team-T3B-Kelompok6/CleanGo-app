import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/payment_flow_controller.dart';

class MidtransCheckoutPage extends StatefulWidget {
  const MidtransCheckoutPage({required this.checkoutUri, super.key});

  final Uri checkoutUri;

  /// Reuse checkout validation without accepting the legacy payment provider.
  static Uri? validatedCheckoutUri(String? url) {
    final uri = PaymentFlowController.checkoutUri(url);
    return uri != null &&
            !uri.hasPort &&
            const {
              'app.midtrans.com',
              'app.sandbox.midtrans.com',
            }.contains(uri.host)
        ? uri
        : null;
  }

  static NavigationDecision navigationDecision(String url) =>
      validatedCheckoutUri(url) == null
      ? NavigationDecision.prevent
      : NavigationDecision.navigate;

  @override
  State<MidtransCheckoutPage> createState() => _MidtransCheckoutPageState();
}

class _MidtransCheckoutPageState extends State<MidtransCheckoutPage> {
  WebViewController? _controller;
  Uri? _initialUri;
  Uri? _retryUri;
  String? _error;
  String? _notice;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _initialUri = MidtransCheckoutPage.validatedCheckoutUri(
      widget.checkoutUri.toString(),
    );
    _retryUri = _initialUri;
    if (_initialUri == null) {
      _error = 'Tautan checkout Midtrans tidak valid. Kembali dan coba lagi.';
      return;
    }
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final decision = MidtransCheckoutPage.navigationDecision(
              request.url,
            );
            if (decision == NavigationDecision.prevent) {
              _showNotice(
                request.url.startsWith('blob:') ||
                        request.url.startsWith('data:')
                    ? 'Unduh QR/blob tidak didukung di halaman ini. Gunakan '
                          'tangkapan layar QR atau buka checkout di browser.'
                    : 'Navigasi ini tidak didukung, termasuk tautan dompet dan '
                          'pengalihan selesai. Pembayaran belum dikonfirmasi. '
                          'Tekan Kembali & Cek Status untuk memeriksa server.',
              );
            } else if (request.isMainFrame) {
              _retryUri = MidtransCheckoutPage.validatedCheckoutUri(
                request.url,
              );
            }
            return decision;
          },
          onPageStarted: (url) {
            final uri = MidtransCheckoutPage.validatedCheckoutUri(url);
            if (!mounted || uri == null) return;
            setState(() {
              _retryUri = uri;
              _progress = 0;
              _error = null;
            });
          },
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            // Subresource failures must not replace a usable checkout page.
            if (error.isForMainFrame == true) {
              _showError(
                'Checkout gagal dimuat. Periksa koneksi lalu coba lagi.',
              );
            }
          },
          onHttpError: (error) {
            if (error.request?.uri == _retryUri) {
              _showError('Server checkout bermasalah. Silakan coba lagi.');
            }
          },
          onSslAuthError: (error) async {
            // webview_flutter 4.14.1 requires cancel or proceed; never bypass TLS.
            await error.cancel();
            _showError('Koneksi checkout tidak aman. Sertifikat ditolak.');
          },
        ),
      );
      if (!mounted) return;
      setState(() => _controller = controller);
      await controller.loadRequest(_initialUri!);
    } catch (_) {
      _showError('Checkout tidak dapat dibuka. Silakan coba lagi.');
    }
  }

  void _showError(String message) {
    if (mounted) setState(() => _error = message);
  }

  void _showNotice(String message) {
    if (mounted) setState(() => _notice = message);
  }

  Future<void> _retry() async {
    final uri = _retryUri;
    if (uri == null) return;
    setState(() {
      _error = null;
      _progress = 0;
    });
    if (_controller == null) {
      await _initialize();
      return;
    }
    try {
      // Retry the failed trusted URL, never a blocked finish/deep link.
      await _controller!.loadRequest(uri);
    } catch (_) {
      _showError('Checkout gagal dimuat. Silakan coba lagi.');
    }
  }

  Future<void> _openBrowser() async {
    final uri = _initialUri;
    if (uri == null) return;
    try {
      // Explicit tap only; never launch URLs supplied by navigation callbacks.
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Keep checkout usable when no external browser is available.
    }
    _showNotice(
      'Browser tidak dapat dibuka. Gunakan perangkat lain untuk scan QR.',
    );
  }

  @override
  Widget build(BuildContext context) {
    // No WebView history interception: system back pops this route too.
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran QRIS')),
      body: Column(
        children: [
          if (_error == null && _progress < 100)
            LinearProgressIndicator(value: _progress / 100),
          if (_notice != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Semantics(liveRegion: true, child: Text(_notice!)),
            ),
          Expanded(
            child: _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          if (_retryUri != null)
                            TextButton(
                              onPressed: _retry,
                              child: const Text('Coba Lagi'),
                            ),
                        ],
                      ),
                    ),
                  )
                : _controller == null
                ? const Center(child: CircularProgressIndicator())
                : WebViewWidget(controller: _controller!),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Unduh QR/blob belum didukung di halaman ini. Untuk HP yang sama, '
              'gunakan tangkapan layar lalu impor QR di dompet jika tersedia, '
              'atau coba unduh lewat browser. Scan QR dengan perangkat lain; '
              'untuk Sandbox gunakan simulator Midtrans, bukan saldo asli. '
              'Status pembayaran hanya dikonfirmasi server.',
              style: TextStyle(fontSize: 12),
            ),
            if (_initialUri != null)
              TextButton(
                onPressed: _openBrowser,
                child: const Text('Buka checkout di browser'),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali & Cek Status'),
            ),
          ],
        ),
      ),
    );
  }
}
