import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/order.dart';
import '../../../core/models/order_status.dart';
import '../../../core/repositories/order_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../widgets/error_retry_view.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _orderRepo = OrderRepository();
  OrderModel? _order;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    // Real loyihada Socket.IO orqali jonli yangilanish keladi (realtime.gateway backend
    // modulida amalga oshirilgan). Bu yerda 10 soniyada bir marta so'rov bilan yetarli.
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _error = null);
    try {
      final order = await _orderRepo.getOrder(widget.orderId);
      if (!mounted) return;
      setState(() => _order = order);
      if (['delivered', 'rejected'].contains(order.status) ||
          order.status.startsWith('cancelled')) {
        _pollTimer?.cancel();
      }
    } catch (_) {
      if (!silent && mounted) setState(() => _error = "Buyurtmani yuklab bo'lmadi");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: ErrorRetryView(message: _error!, onRetry: _load));
    }
    if (_order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final order = _order!;
    final isCancelled = order.status.startsWith('cancelled') || order.status == 'rejected';
    final stepIndex = OrderStatusInfo.stepIndex(order.status);

    return Scaffold(
      appBar: AppBar(title: Text('Buyurtma №${order.orderNumber}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.tomatoSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Icon(
                  isCancelled ? Icons.cancel_rounded : Icons.delivery_dining_rounded,
                  size: 40,
                  color: isCancelled ? AppColors.danger : AppColors.tomato,
                ),
                const SizedBox(height: 10),
                Text(
                  OrderStatusInfo.label(order.status),
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                if (order.restaurantName != null) ...[
                  const SizedBox(height: 4),
                  Text(order.restaurantName!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),

          if (!isCancelled) ...[
            const SizedBox(height: 24),
            _ProgressTracker(currentStep: stepIndex),
          ],

          const SizedBox(height: 24),
          Text('Buyurtma tarkibi', style: AppTextStyles.h2),
          const SizedBox(height: 10),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${item.quantity}x ${item.productName ?? ''}', style: AppTextStyles.body),
                  ),
                  Text(Formatters.price(item.totalPrice), style: AppTextStyles.body),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          _SummaryRow(label: 'Mahsulotlar', value: Formatters.price(order.subtotal)),
          _SummaryRow(
            label: 'Yetkazib berish',
            value: order.deliveryFee == 0 ? 'Bepul' : Formatters.price(order.deliveryFee),
          ),
          if (order.discountAmount > 0)
            _SummaryRow(label: 'Chegirma', value: '-${Formatters.price(order.discountAmount)}'),
          if (order.bonusUsed > 0)
            _SummaryRow(label: 'Bonus ishlatildi', value: '-${Formatters.price(order.bonusUsed)}'),
          const Divider(height: 24),
          _SummaryRow(label: 'Jami', value: Formatters.price(order.totalAmount), isTotal: true),
          const SizedBox(height: 12),
          Text('Buyurtma vaqti: ${Formatters.dateTime(order.createdAt)}', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ProgressTracker extends StatelessWidget {
  final int currentStep;

  const _ProgressTracker({required this.currentStep});

  static const _labels = ['Qabul', 'Tasdiq', 'Tayyor', 'Kuryer', 'Olindi', "Yo'lda", 'Yetkazildi'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (index) {
        final isDone = index <= currentStep;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index <= currentStep ? AppColors.tomato : AppColors.line,
                      ),
                    ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? AppColors.tomato : AppColors.line,
                    ),
                  ),
                  if (index < _labels.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < currentStep ? AppColors.tomato : AppColors.line,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _labels[index],
                style: AppTextStyles.small.copyWith(
                  color: isDone ? AppColors.charcoal : AppColors.textFaint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    final style = isTotal ? AppTextStyles.h2 : AppTextStyles.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: isTotal ? AppColors.charcoal : AppColors.textMuted)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
