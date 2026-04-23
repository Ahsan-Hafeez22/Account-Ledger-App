import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:account_ledger/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:account_ledger/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:account_ledger/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:account_ledger/features/chat/domain/repositories/chat_repository.dart';
import 'package:account_ledger/features/chat/domain/usecases/listen_messages_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/listen_typing_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/listen_user_status_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/open_chat_usecase.dart';
import 'package:account_ledger/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:account_ledger/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:get_it/get_it.dart';

void initChatInjection(GetIt sl) {
  sl.registerLazySingleton<ChatSocketDataSource>(ChatSocketDataSourceImpl.new);
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      socket: sl(),
      remote: sl(),
      tokenStorage: sl<TokenStorageDataSource>(),
    ),
  );

  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => OpenChatUseCase(sl()));
  sl.registerLazySingleton(() => ListenMessagesUseCase(sl()));
  sl.registerLazySingleton(() => ListenMessageStatusUseCase(sl()));
  sl.registerLazySingleton(() => ListenTypingUseCase(sl()));
  sl.registerLazySingleton(() => ListenUserStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetChatMessagesUseCase(sl()));

  // App-scoped bloc so navigation doesn't disconnect/reconnect the socket.
  sl.registerLazySingleton(
    () => ChatBloc(
      repository: sl(),
      sendMessage: sl(),
      openChat: sl(),
      listenMessages: sl(),
      listenMessageStatus: sl(),
      listenTyping: sl(),
      listenUserStatus: sl(),
      getUserStatus: sl(),
      getChatMessages: sl(),
    ),
  );
}

