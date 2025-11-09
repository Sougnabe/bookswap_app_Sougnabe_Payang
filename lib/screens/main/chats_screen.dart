import 'package:bookswap_app/models/swap_offer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/providers/swap_provider.dart';
import 'package:bookswap_app/providers/auth_provider.dart';
import 'package:bookswap_app/screens/main/chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final swapProvider = Provider.of<SwapProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final allOffers = [...swapProvider.sentOffers, ...swapProvider.receivedOffers]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final chatOffers = allOffers.where((offer) => offer.status.index <= SwapStatus.accepted.index).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: swapProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatOffers.isEmpty
              ? const Center(
                  child: Text(
                    'No active chats yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatOffers.length,
                  itemBuilder: (context, index) {
                    final offer = chatOffers[index];
                    final isSentByMe = offer.senderId == authProvider.user?.id;
                    final otherUserName = isSentByMe ? offer.receiverName : offer.senderName;
                    final bookTitle = offer.bookTitle;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            otherUserName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(otherUserName),
                        subtitle: Text('About: $bookTitle'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(offer.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            offer.statusString,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(swapOffer: offer),
                            ),
                          );
                        },
                      ),
                    );
                  },
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
}