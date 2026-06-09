import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/payment_plan.dart';
import '../../widgets/primary_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final PaymentPlan plan;
  const PaymentSuccessScreen({required this.plan, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            Text('Đã nâng cấp ${plan.displayName}!'),
            PrimaryButton(label: 'Về trang chủ', onPressed: () => context.go('/dashboard')),
          ],
        ),
      ),
    );
  }
}