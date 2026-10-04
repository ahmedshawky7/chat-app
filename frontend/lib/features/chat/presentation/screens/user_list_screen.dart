import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_app/core/network/dio_client.dart';
import 'package:frontend_app/core/network/websocket_service.dart';
import 'package:frontend_app/core/utils/token_storage.dart';
import 'package:frontend_app/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend_app/features/chat/data/models/user_model.dart';
import 'package:frontend_app/features/chat/data/repositories/chat_repository.dart';
import 'package:frontend_app/features/chat/logic/cubit/chat_cubit.dart';
import 'package:frontend_app/features/chat/presentation/screens/chat_screen.dart';

class UserListScreen extends StatefulWidget {
  final int currentUserId;
  final String currentUserEmail;
  const UserListScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserEmail,
  });

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _chatRepository = ChatRepository(DioClient());
  late Future<(List<UserModel>, Map<int, int>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<(List<UserModel>, Map<int, int>)> _loadData() async {
    final users = await _chatRepository.getAllUsers();
    final unread = await _chatRepository.getUnreadCounts();
    return (users, unread);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await TokenStorage.deleteToken();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<(List<UserModel>, Map<int, int>)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          final (users, unreadCounts) = snapshot.data!;

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final unreadCount = unreadCounts[user.id] ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(user.username),
                subtitle: Text(user.email),
                trailing: unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => ChatCubit(
                          ChatRepository(DioClient()),
                          WebsocketService(DioClient()),
                        ),
                        child: ChatScreen(
                          email: widget.currentUserEmail,
                          currentUserId: widget.currentUserId,
                          otherUserId: user.id,
                          otherUserEmail: user.email,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}