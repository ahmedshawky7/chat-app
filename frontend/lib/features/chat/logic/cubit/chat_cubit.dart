import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_app/core/network/websocket_service.dart';
import 'package:frontend_app/features/chat/data/models/message_model.dart';
import 'package:frontend_app/features/chat/data/repositories/chat_repository.dart';
import 'package:frontend_app/features/chat/logic/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  final WebsocketService websocketService;

  ChatCubit(this.chatRepository, this.websocketService) : super(ChatInitial());

  Future<void> initChat({
    required int otherUserId,
    required int currentUserId,
  }) async {
    emit(const ChatLoading());
    try {
      await websocketService.connect(_onMessageReceived, _onReadReceipt);
      final messages = await chatRepository.getConversation(otherUserId);
      emit(ChatLoaded(messages, otherUserId));

      // ← جديد: بعد ما الشات يتحمّل، اعمل mark as read
      await chatRepository.markAsRead(otherUserId);
    } catch (e) {
      emit(ChatError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onMessageReceived(Map<String, dynamic> data) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final newMessage = MessageModel.fromJson(data);

      // ← فلتر: بس الرسايل بيني وبين otherUser (في الاتجاهين)
      final isFromOther = newMessage.senderId == currentState.otherUserId;
      final isToOther = newMessage.receiverId == currentState.otherUserId;

      if (!isFromOther && !isToOther) {
        return; // مش من المحادثة دي، متضفهاش
      }

      final updatedMessages = List<MessageModel>.from(currentState.messages)
        ..add(newMessage);
      emit(ChatLoaded(updatedMessages, currentState.otherUserId));

      // ← علّم كمقروءة فقط لو الرسالة جاية من الطرف التاني
      if (isFromOther) {
        chatRepository.markAsRead(currentState.otherUserId);
      }
    }
  }

  void _onReadReceipt(Map<String, dynamic> data) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final List<dynamic> rawIds = data['messageIds'] as List<dynamic>;
      final Set<int> readIds = rawIds.map((id) => id as int).toSet();

      final updatedMessages = currentState.messages.map((message) {
        if (message.senderId != currentState.otherUserId &&
            readIds.contains(message.id)) {
          return message.copyWith(isRead: true);
        }
        return message;
      }).toList();
      emit(ChatLoaded(updatedMessages, currentState.otherUserId));
    }
  }

  void sendMessage(int receiverId, String content) {
    websocketService.sendMessage(receiverId, content);
  }

  void leaveChat() {
    websocketService.disconnect();
    emit(const ChatInitial());
  }

  @override
  Future<void> close() {
    websocketService.disconnect();
    return super.close();
  }
}
