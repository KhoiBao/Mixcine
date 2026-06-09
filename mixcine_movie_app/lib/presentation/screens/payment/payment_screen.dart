import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../domain/entities/payment_plan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final PaymentPlan plan;
  const PaymentScreen({required this.paymentUrl, required this.plan, super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('vnp_ResponseCode')) {
              _handleResult(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleResult(String url) async {
    final uri = Uri.parse(url);
    final userId = ref.read(authStateProvider).user?.email ?? 'guest';

    final success = await ref.read(paymentProvider.notifier).processPaymentResult(
      result: uri.queryParameters,
      plan: widget.plan,
      userId: userId,
    );

    if (success && mounted) {
      context.pushReplacement('/payment-success', extra: widget.plan);
    } else if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPAY'),
        actions: [
          // NÚT SKIP THANH TOÁN
          TextButton.icon(
            onPressed: () async {
              final userId = ref.read(authStateProvider).user?.email ?? 'guest';

              // Vẫn gọi hàm xử lý, thêm vài data giả cho nó khỏi văng lỗi parse
              await ref.read(paymentProvider.notifier).processPaymentResult(
                result: {
                  'vnp_ResponseCode': '00',
                  'vnp_TransactionNo': '999999',
                  'vnp_Amount': '10000000'
                },
                plan: widget.plan,
                userId: userId,
              );

              // Bỏ qua check success luôn, ép navigate thẳng sang màn hình Success để test
              if (context.mounted) {
                context.pushReplacement('/payment-success', extra: widget.plan);
              }
            },
            icon: const Icon(Icons.fast_forward_rounded, color: Colors.orangeAccent),
            label: const Text(
              'Skip thanh toán',
              style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}