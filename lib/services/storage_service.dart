import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Upload a book image to Firebase Storage
  Future<String?> uploadBookImage(XFile imageFile, String userId) async {
    try {
      // First, check if storage is accessible
      final isAccessible = await checkStorageConfiguration();
      if (!isAccessible) {
        throw Exception(
          'Firebase Storage is not enabled or configured.\n\n'
          'Please enable Storage in Firebase Console:\n'
          '1. Go to console.firebase.google.com\n'
          '2. Select your project\n'
          '3. Click Storage → Get Started\n'
          '4. Follow the setup wizard'
        );
      }

      final String fileName = 'book_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child('book_images/$userId/$fileName');
      
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();
      
      // Upload with metadata
      final UploadTask uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('❌ Firebase Storage Error: ${e.code} - ${e.message}');
      
      if (e.code == 'storage/unauthorized') {
        throw Exception(
          'Storage access denied.\n\n'
          'Fix: Deploy storage rules or enable Storage in Firebase Console.'
        );
      } else if (e.code == 'storage/object-not-found') {
        throw Exception(
          'Firebase Storage not found.\n\n'
          'Please enable Storage:\n'
          '1. Open Firebase Console\n'
          '2. Go to Storage section\n'
          '3. Click "Get Started"\n'
          '4. Complete the setup wizard'
        );
      } else if (e.code == 'storage/canceled') {
        throw Exception('Upload was canceled.');
      } else if (e.code == 'storage/unknown') {
        throw Exception(
          'Storage error occurred.\n\n'
          'Please enable Firebase Storage in your Firebase Console.'
        );
      }
      
      rethrow;
    } catch (e) {
      print('❌ Upload Error: $e');
      
      // If it's already our custom exception, rethrow it
      if (e is Exception) rethrow;
      
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Pick an image from gallery
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        print('✅ Image selected: ${image.path}');
      }
      
      return image;
    } catch (e) {
      print('❌ Image picker error: $e');
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick an image from camera
  Future<XFile?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        print('✅ Photo taken: ${image.path}');
      }
      
      return image;
    } catch (e) {
      print('❌ Camera error: $e');
      throw Exception('Failed to take photo: $e');
    }
  }

  /// Delete an image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Image deleted successfully');
    } on FirebaseException catch (e) {
      print('❌ Delete Error: ${e.code} - ${e.message}');
      
      if (e.code == 'storage/object-not-found') {
        print('⚠️  Image already deleted or does not exist');
        return; // Not really an error if already deleted
      }
      
      rethrow;
    } catch (e) {
      print('❌ Error deleting image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Check if Firebase Storage is properly configured
  Future<bool> checkStorageConfiguration() async {
    try {
      // Try to get the root reference and list it
      final ref = _storage.ref();
      await ref.listAll();
      print('✅ Firebase Storage is properly configured');
      return true;
    } on FirebaseException catch (e) {
      print('❌ Storage Configuration Error: ${e.code} - ${e.message}');
      
      if (e.code == 'storage/unauthorized') {
        print('⚠️  Storage rules need to be configured');
        print('   Run: firebase deploy --only storage');
      } else if (e.code == 'storage/object-not-found') {
        print('⚠️  Firebase Storage is not enabled');
        print('   Enable it in Firebase Console → Storage');
      }
      
      return false;
    } catch (e) {
      print('❌ Storage check error: $e');
      return false;
    }
  }
  
  /// Get a placeholder image URL (use when Storage isn't available)
  String getPlaceholderImage(String bookTitle) {
    // Use a placeholder service that doesn't require storage
    final encodedTitle = Uri.encodeComponent(bookTitle);
    return 'https://via.placeholder.com/400x600/4A148C/FFFFFF?text=$encodedTitle';
  }
}