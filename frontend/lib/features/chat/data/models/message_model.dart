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
}
