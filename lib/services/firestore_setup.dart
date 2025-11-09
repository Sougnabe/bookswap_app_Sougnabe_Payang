import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookswap_app/models/book_listing.dart';
import 'package:bookswap_app/models/user_model.dart';

/// Helper class to set up Firestore collections and indexes
class FirestoreSetup {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize user profile in Firestore
  Future<void> createUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      print('✅ User profile created for ${user.displayName}');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      rethrow;
    }
  }

  /// Create sample book listings for testing
  Future<void> createSampleBooks(String userId, String userName) async {
    final sampleBooks = [
      BookListing(
        id: 'book_${DateTime.now().millisecondsSinceEpoch}_1',
        title: 'The Great Gatsby',
        author: 'F. Scott Fitzgerald',
        condition: BookCondition.good,
        imageUrl: 'https://covers.openlibrary.org/b/id/7222246-L.jpg',
        ownerId: userId,
        ownerName: userName,
        createdAt: DateTime.now(),
        isAvailable: true,
      ),
      BookListing(
        id: 'book_${DateTime.now().millisecondsSinceEpoch}_2',
        title: 'To Kill a Mockingbird',
        author: 'Harper Lee',
        condition: BookCondition.likeNew,
        imageUrl: 'https://covers.openlibrary.org/b/id/8231634-L.jpg',
        ownerId: userId,
        ownerName: userName,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isAvailable: true,
      ),
      BookListing(
        id: 'book_${DateTime.now().millisecondsSinceEpoch}_3',
        title: '1984',
        author: 'George Orwell',
        condition: BookCondition.good,
        imageUrl: 'https://covers.openlibrary.org/b/id/7222246-L.jpg',
        ownerId: userId,
        ownerName: userName,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isAvailable: true,
      ),
    ];

    try {
      for (var book in sampleBooks) {
        await _firestore.collection('book_listings').doc(book.id).set(book.toMap());
        print('✅ Created book: ${book.title}');
      }
    } catch (e) {
      print('❌ Error creating sample books: $e');
      rethrow;
    }
  }

  /// Verify all required collections exist and are accessible
  Future<Map<String, dynamic>> verifyCollections() async {
    final result = {
      'users': false,
      'book_listings': false,
      'swap_offers': false,
      'chats': false,
    };

    try {
      // Check users collection
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      result['users'] = true;
      print('✅ Users collection accessible (${usersSnapshot.docs.length} documents)');
    } catch (e) {
      print('❌ Users collection error: $e');
    }

    try {
      // Check book_listings collection
      final booksSnapshot = await _firestore.collection('book_listings').limit(1).get();
      result['book_listings'] = true;
      print('✅ Book listings collection accessible (${booksSnapshot.docs.length} documents)');
    } catch (e) {
      print('❌ Book listings collection error: $e');
    }

    try {
      // Check swap_offers collection
      final swapsSnapshot = await _firestore.collection('swap_offers').limit(1).get();
      result['swap_offers'] = true;
      print('✅ Swap offers collection accessible (${swapsSnapshot.docs.length} documents)');
    } catch (e) {
      print('❌ Swap offers collection error: $e');
    }

    try {
      // Check chats collection
      final chatsSnapshot = await _firestore.collection('chats').limit(1).get();
      result['chats'] = true;
      print('✅ Chats collection accessible (${chatsSnapshot.docs.length} documents)');
    } catch (e) {
      print('❌ Chats collection error: $e');
    }

    return result;
  }

  /// Get collection statistics
  Future<void> printCollectionStats() async {
    print('\n📊 Firestore Collection Statistics:');
    print('=' * 50);

    try {
      final usersCount = await _firestore.collection('users').count().get();
      print('Users: ${usersCount.count} documents');
    } catch (e) {
      print('Users: Error - $e');
    }

    try {
      final booksCount = await _firestore.collection('book_listings').count().get();
      print('Book Listings: ${booksCount.count} documents');
    } catch (e) {
      print('Book Listings: Error - $e');
    }

    try {
      final swapsCount = await _firestore.collection('swap_offers').count().get();
      print('Swap Offers: ${swapsCount.count} documents');
    } catch (e) {
      print('Swap Offers: Error - $e');
    }

    try {
      final chatsCount = await _firestore.collection('chats').count().get();
      print('Chats: ${chatsCount.count} documents');
    } catch (e) {
      print('Chats: Error - $e');
    }

    print('=' * 50);
  }

  /// Clear all test data (use with caution!)
  Future<void> clearAllTestData() async {
    print('⚠️  WARNING: This will delete ALL data from Firestore!');
    
    try {
      // Delete all books
      final booksSnapshot = await _firestore.collection('book_listings').get();
      for (var doc in booksSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Deleted ${booksSnapshot.docs.length} book listings');

      // Delete all swap offers
      final swapsSnapshot = await _firestore.collection('swap_offers').get();
      for (var doc in swapsSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Deleted ${swapsSnapshot.docs.length} swap offers');

      // Delete all chats
      final chatsSnapshot = await _firestore.collection('chats').get();
      for (var doc in chatsSnapshot.docs) {
        // Delete subcollection messages first
        final messagesSnapshot = await doc.reference.collection('messages').get();
        for (var messageDoc in messagesSnapshot.docs) {
          await messageDoc.reference.delete();
        }
        await doc.reference.delete();
      }
      print('✅ Deleted ${chatsSnapshot.docs.length} chats');

      print('✅ All test data cleared!');
    } catch (e) {
      print('❌ Error clearing test data: $e');
      rethrow;
    }
  }
}
