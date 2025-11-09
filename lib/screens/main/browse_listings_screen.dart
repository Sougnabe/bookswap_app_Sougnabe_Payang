import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bookswap_app/providers/book_provider.dart';
import 'package:bookswap_app/providers/swap_provider.dart';
import 'package:bookswap_app/providers/auth_provider.dart';

class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final swapProvider = Provider.of<SwapProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: bookProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookProvider.allBooks.isEmpty
              ? const Center(
                  child: Text(
                    'No books available yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookProvider.allBooks.length,
                  itemBuilder: (context, index) {
                    final book = bookProvider.allBooks[index];
                    final isOwnBook = book.ownerId == authProvider.user?.id;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: book.imageUrl,
                                width: 80,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 80,
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.book, color: Colors.grey),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 80,
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'by ${book.author}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          book.conditionString,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Listed by: ${book.ownerName}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isOwnBook)
                              IconButton(
                                onPressed: () async {
                                  final success = await swapProvider.createSwapOffer(
                                    bookId: book.id,
                                    bookTitle: book.title,
                                    bookImageUrl: book.imageUrl,
                                    senderId: authProvider.user!.id,
                                    senderName: authProvider.user!.displayName,
                                    receiverId: book.ownerId,
                                    receiverName: book.ownerName,
                                  );
                                  
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Swap offer sent successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to send swap offer: ${swapProvider.error}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.swap_horiz, color: Colors.deepPurple),
                                tooltip: 'Request Swap',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}