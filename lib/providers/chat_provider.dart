import 'package:flutter/foundation.dart';
import 'package:bookswap_app/models/chat_message.dart';
import 'package:bookswap_app/services/firestore_service.dart';

class ChatProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  
  Map<String, List<ChatMessage>> _chatMessages = {};
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._firestoreService);

  Map<String, List<ChatMessage>> get chatMessages => _chatMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initializeChat(String chatId) {
    _firestoreService.getChatMessages(chatId).listen((messages) {
      _chatMessages[chatId] = messages;
      notifyListeners();
    });
  }

  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final chatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        message: message,
        timestamp: DateTime.now(),
      );

      await _firestoreService.sendMessage(chatMessage);
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

  List<ChatMessage> getMessagesForChat(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}