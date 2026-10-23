import 'package:flutter/material.dart';

enum OrderStatus {
  processing,
  inTransit,
  completed,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.processing:
        return 'Tailoring & Processing';
      case OrderStatus.inTransit:
        return 'Out for Delivery';
      case OrderStatus.completed:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.processing:
        return const Color(0xFFD97706);
      case OrderStatus.inTransit:
        return const Color(0xFF2563EB);
      case OrderStatus.completed:
        return const Color(0xFF16A34A);
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.processing:
        return const Color(0xFFFEF3C7);
      case OrderStatus.inTransit:
        return const Color(0xFFDBEAFE);
      case OrderStatus.completed:
        return const Color(0xFFDCFCE7);
      case OrderStatus.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }
}

class OrderItem {
  final String name;
  final String category;
  final int quantity;
  final String size;
  final String color;
  final double price;
  final String imageUrl;

  const OrderItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.size,
    required this.color,
    required this.price,
    required this.imageUrl,
  });
}

class OrderTimelineStep {
  final String title;
  final String subtitle;
  final String date;
  final bool isCompleted;
  final bool isCurrent;

  const OrderTimelineStep({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isCompleted,
    this.isCurrent = false,
  });
}

class OrderModel {
  final String id;
  final DateTime orderDate;
  final OrderStatus status;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final String trackingNumber;
  final String deliveryAddress;
  final String estimatedDelivery;
  final List<OrderTimelineStep> timeline;

  const OrderModel({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    required this.trackingNumber,
    required this.deliveryAddress,
    required this.estimatedDelivery,
    required this.timeline,
  });
}
