class MessageModel {
  final int id;

  final String content;

  final int senderId;

  final String senderUsername;

  final int receiverId;

  final DateTime timestamp;

  final bool isRead;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderUsername,
    required this.receiverId,
    required this.timestamp,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      senderId: json['senderId'],
      senderUsername: json['senderUsername'],
      receiverId: json['receiverId'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
    );
  }
  MessageModel copyWith({
    int? id,
    String? content,
    int? senderId,
    String? senderUsername,
    int? receiverId,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      receiverId: receiverId ?? this.receiverId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
