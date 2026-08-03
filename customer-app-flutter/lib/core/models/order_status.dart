import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OrderStatusInfo {
  static const Map<String, String> labels = {
    'created': 'Qabul qilinmoqda',
    'accepted_by_restaurant': 'Restoran qabul qildi',
    'preparing': 'Tayyorlanmoqda',
    'ready_for_pickup': 'Kuryer kutilmoqda',
    'courier_assigned': 'Kuryer biriktirildi',
    'picked_up': 'Kuryer oldi',
    'on_the_way': "Yo'lda",
    'delivered': 'Yetkazildi',
    'cancelled_by_customer': 'Bekor qilindi',
    'cancelled_by_restaurant': 'Restoran bekor qildi',
    'rejected': 'Rad etildi',
  };

  static String label(String status) => labels[status] ?? status;

  static Color color(String status) {
    if (status == 'delivered') return AppColors.success;
    if (status.startsWith('cancelled') || status == 'rejected') return AppColors.danger;
    if (status == 'created' || status == 'accepted_by_restaurant') return AppColors.warning;
    return AppColors.tomato;
  }

  /// Buyurtma bosqichlari (progress indikator uchun), yakuniy/bekor holatlar bundan tashqarida
  static const List<String> progressSteps = [
    'created',
    'accepted_by_restaurant',
    'preparing',
    'ready_for_pickup',
    'courier_assigned',
    'on_the_way',
    'delivered',
  ];

  static int stepIndex(String status) {
    final idx = progressSteps.indexOf(status);
    return idx == -1 ? 0 : idx;
  }

  static bool get isTerminalCancelled => false;
}
