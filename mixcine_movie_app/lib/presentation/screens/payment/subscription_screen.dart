import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/payment_plan.dart';
import '../../providers/payment_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/branded_screen_header.dart';
import '../../widgets/primary_button.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSubscription = ref.watch(subscriptionProvider);
    final paymentState = ref.watch(paymentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nâng cấp tài khoản')),
      body: SafeArea(
        child: paymentState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: PaymentPlan.values.map((plan) {
              final isCurrent = currentSubscription?.plan == plan &&
                  (currentSubscription?.isActive ?? false);
              return _PlanCard(
                plan: plan,
                isCurrent: isCurrent,
                onSelect: () async {
                  if (isCurrent || plan == PaymentPlan.free) return;
                  final url = await ref.read(paymentProvider.notifier).getPaymentUrl(plan);
                  if (url != null && context.mounted) {
                    context.push('/payment', extra: {'url': url, 'plan': plan});
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PaymentPlan plan;
  final bool isCurrent;
  final VoidCallback onSelect;
  const _PlanCard({required this.plan, required this.isCurrent, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(plan.displayName, style: Theme.of(context).textTheme.headlineMedium),
            Text(plan.formattedPrice),
            const SizedBox(height: 10),
            Text(plan.description),
            const SizedBox(height: 10),
            if (!isCurrent && plan != PaymentPlan.free)
              PrimaryButton(label: 'Mua ngay', onPressed: onSelect),
          ],
        ),
      ),
    );
  }
}