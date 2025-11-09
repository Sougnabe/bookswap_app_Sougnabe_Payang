import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookswap_app/models/book_listing.dart';
import 'package:bookswap_app/models/swap_offer.dart';
import 'package:bookswap_app/models/chat_message.dart';
import 'package:bookswap_app/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Book Listings CRUD
  Stream<List<BookListing>> getBookListings() {
    return _firestore
        .collection('book_listings')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookListing.fromMap(doc.data()))
            .toList());
  }

  Stream<List<BookListing>> getUserBookListings(String userId) {
    return _firestore
        .collection('book_listings')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookListing.fromMap(doc.data()))
            .toList());
  }

  Future<void> addBookListing(BookListing book) async {
    await _firestore.collection('book_listings').doc(book.id).set(book.toMap());
  }

  Future<void> updateBookListing(BookListing book) async {
    await _firestore.collection('book_listings').doc(book.id).update(book.toMap());
  }

  Future<void> deleteBookListing(String bookId) async {
    await _firestore.collection('book_listings').doc(bookId).delete();
  }

  // Swap Offers
  Stream<List<SwapOffer>> getUserSwapOffers(String userId) {
    return _firestore
        .collection('swap_offers')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapOffer.fromMap(doc.data()))
            .toList());
  }

  Stream<List<SwapOffer>> getReceivedSwapOffers(String userId) {
    return _firestore
        .collection('swap_offers')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapOffer.fromMap(doc.data()))
            .toList());
  }

  Future<void> createSwapOffer(SwapOffer offer) async {
    final batch = _firestore.batch();
    
    // Add swap offer
    batch.set(
      _firestore.collection('swap_offers').doc(offer.id),
      offer.toMap(),
    );
    
    // Update book listing to not available
    batch.update(
      _firestore.collection('book_listings').doc(offer.bookId),
      {'isAvailable': false},
    );
    
    await batch.commit();
  }

  Future<void> updateSwapOfferStatus(String offerId, SwapStatus status) async {
    await _firestore.collection('swap_offers').doc(offerId).update({
      'status': status.index,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Chat Messages
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage(ChatMessage message) async {
    await _firestore
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  // User Profile
  Future<void> updateUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<AppUser?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }
}