import 'package:equatable/equatable.dart';
import 'package:frontend_app/features/chat/data/models/message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState { const ChatInitial(); }
class ChatLoading extends ChatState { const ChatLoading(); }

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final int otherUserId;
  const ChatLoaded(this.messages, this.otherUserId);
  @override
  List<Object?> get props => [messages, otherUserId];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}