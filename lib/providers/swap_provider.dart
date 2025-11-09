import 'package:flutter/foundation.dart';
import 'package:bookswap_app/models/swap_offer.dart';
import 'package:bookswap_app/services/firestore_service.dart';

class SwapProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  
  List<SwapOffer> _sentOffers = [];
  List<SwapOffer> _receivedOffers = [];
  bool _isLoading = false;
  String? _error;

  SwapProvider(this._firestoreService);

  List<SwapOffer> get sentOffers => _sentOffers;
  List<SwapOffer> get receivedOffers => _receivedOffers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initialize(String userId) {
    _firestoreService.getUserSwapOffers(userId).listen((offers) {
      _sentOffers = offers;
      notifyListeners();
    });

    _firestoreService.getReceivedSwapOffers(userId).listen((offers) {
      _receivedOffers = offers;
      notifyListeners();
    });
  }

  Future<bool> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String bookImageUrl,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final offer = SwapOffer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: bookId,
        bookTitle: bookTitle,
        bookImageUrl: bookImageUrl,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        receiverName: receiverName,
        status: SwapStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createSwapOffer(offer);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOfferStatus(String offerId, SwapStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateSwapOfferStatus(offerId, status);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}