import 'dart:convert';

import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/storage/secure_storage_datasource.dart';

class PendingTransferPayload {
  final String idempotencyKey;
  final String toAccount;
  final double amount;
  final String description;

  const PendingTransferPayload({
    required this.idempotencyKey,
    required this.toAccount,
    required this.amount,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'toAccount': toAccount,
    'amount': amount,
    'description': description,
  };

  factory PendingTransferPayload.fromJson(Map<String, dynamic> json) {
    return PendingTransferPayload(
      idempotencyKey: json['idempotencyKey'] as String? ?? '',
      toAccount: json['toAccount'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
    );
  }
}

abstract class TransactionPendingLocalDatasource {
  Future<PendingTransferPayload?> readPending();

  Future<void> savePending(PendingTransferPayload payload);

  Future<void> clearPending();
}

class TransactionPendingLocalDatasourceImpl
    implements TransactionPendingLocalDatasource {
  TransactionPendingLocalDatasourceImpl({
    required SecureStorageDataSource secureStorage,
  }) : _secureStorage = secureStorage;

  static const _storageKey = 'ledger_pending_transfer_v1';

  final SecureStorageDataSource _secureStorage;

  @override
  Future<void> clearPending() async {
    try {
      await _secureStorage.delete(key: _storageKey);
    } on CacheException {
      rethrow;
    }
  }

  @override
  Future<PendingTransferPayload?> readPending() async {
    try {
      final raw = await _secureStorage.read(key: _storageKey);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      return PendingTransferPayload.fromJson(map);
    } on CacheException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePending(PendingTransferPayload payload) async {
    try {
      await _secureStorage.write(
        key: _storageKey,
        value: jsonEncode(payload.toJson()),
      );
    } on CacheException {
      rethrow;
    }
  }
}
