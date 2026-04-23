import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/chat/data/models/message_model.dart';
import 'package:dio/dio.dart';

abstract interface class ChatRemoteDataSource {
  Future<List<MessageModel>> getMessages({
    required String senderId,
    required String receiverId,
    required int page,
    required int limit,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;
  const ChatRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  Never _throwTypedDio(DioException e, String scope) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message = 'Request failed. Please try again.';
    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) message = m;
    }
    throw ServerException(
      message: message,
      code: '$scope-failed-${statusCode ?? 'unknown'}',
      details: data ?? e.toString(),
    );
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String senderId,
    required String receiverId,
    required int page,
    required int limit,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.chatMessages,
        queryParameters: {
          'senderId': senderId,
          'receiverId': receiverId,
          'page': page,
          'limit': limit,
        },
      );

      final data = res.data;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (data is Map<String, dynamic>) {
        final list = data['messages'] ?? data['data'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return const [];
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'get-chat-messages');
    }
  }
}

