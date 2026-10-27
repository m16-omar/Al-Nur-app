import 'package:alnur_store_server/src/idempotency/idempotency_manager.dart';
import 'package:test/test.dart';

void main() {
  group('IdempotencyManager Request Hashing', () {
    test('produces identical hash regardless of map key ordering', () {
      final payload1 = {
        'customerEmail': 'amina@alnur.store',
        'totalAmount': 28500.0,
        'shippingAddress': 'Lekki Phase 1, Lagos',
      };

      final payload2 = {
        'shippingAddress': 'Lekki Phase 1, Lagos',
        'customerEmail': 'amina@alnur.store',
        'totalAmount': 28500.0,
      };

      final hash1 = IdempotencyManager.generateRequestHash('order.createOrder', payload1);
      final hash2 = IdempotencyManager.generateRequestHash('order.createOrder', payload2);

      expect(hash1, equals(hash2));
    });

    test('produces different hash when payload parameters differ', () {
      final payload1 = {
        'customerEmail': 'amina@alnur.store',
        'totalAmount': 28500.0,
      };

      final payload2 = {
        'customerEmail': 'amina@alnur.store',
        'totalAmount': 35000.0, // Different amount
      };

      final hash1 = IdempotencyManager.generateRequestHash('order.createOrder', payload1);
      final hash2 = IdempotencyManager.generateRequestHash('order.createOrder', payload2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('produces different hash for different endpoints', () {
      final payload = {
        'totalAmount': 28500.0,
      };

      final hash1 = IdempotencyManager.generateRequestHash('order.createOrder', payload);
      final hash2 = IdempotencyManager.generateRequestHash('order.previewOrder', payload);

      expect(hash1, isNot(equals(hash2)));
    });
  });
}
