import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/models/swap_offer.dart';
import 'package:bookswap_app/providers/chat_provider.dart';
import 'package:bookswap_app/providers/auth_provider.dart';
import 'package:bookswap_app/providers/swap_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final SwapOffer swapOffer;

  const ChatDetailScreen({super.key, required this.swapOffer});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.initializeChat(widget.swapOffer.id);
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    chatProvider.sendMessage(
      chatId: widget.swapOffer.id,
      senderId: authProvider.user!.id,
      senderName: authProvider.user!.displayName,
      message: message,
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final swapProvider = Provider.of<SwapProvider>(context);

    final messages = chatProvider.getMessagesForChat(widget.swapOffer.id);
    final isSentByMe = widget.swapOffer.senderId == authProvider.user?.id;
    final otherUserName = isSentByMe ? widget.swapOffer.receiverName : widget.swapOffer.senderName;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherUserName),
            Text(
              widget.swapOffer.bookTitle,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isSentByMe && widget.swapOffer.status == SwapStatus.pending)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'accept',
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Accept Swap'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Row(
                    children: [
                      Icon(Icons.close, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Reject Swap'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'accept') {
                  final success = await swapProvider.updateOfferStatus(
                    widget.swapOffer.id,
                    SwapStatus.accepted,
                  );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Swap accepted!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else if (value == 'reject') {
                  final success = await swapProvider.updateOfferStatus(
                    widget.swapOffer.id,
                    SwapStatus.rejected,
                  );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Swap rejected.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.swapOffer.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.swapOffer.statusString,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Swap Status: ${widget.swapOffer.statusString}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.\nStart the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == authProvider.user?.id;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.deepPurple : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Text(
                                  message.senderName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(
                                message.message,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (widget.swapOffer.status.index <= SwapStatus.accepted.index)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Colors.orange;
      case SwapStatus.accepted:
        return Colors.green;
      case SwapStatus.rejected:
        return Colors.red;
      case SwapStatus.completed:
        return Colors.blue;
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}