import 'package:mobx/mobx.dart';
import '../../data/datasources/chatbot_remote_datasource.dart';

part 'chatbot_store.g.dart';

class ChatMessage {
  final String role; // 'user' atau 'assistant'
  final String content;

  ChatMessage({required this.role, required this.content});
}

class ChatbotStore = ChatbotStoreBase with _$ChatbotStore;

abstract class ChatbotStoreBase with Store {
  final ChatbotRemoteDataSource _dataSource;

  ChatbotStoreBase(this._dataSource);

  @observable
  ObservableList<ChatMessage> messages = ObservableList<ChatMessage>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = text.trim();
    messages.add(ChatMessage(role: 'user', content: userMsg));
    isLoading = true;
    errorMessage = null;

    try {
      final historyList = messages
          .sublist(0, messages.length - 1)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final reply = await _dataSource.sendMessage(
        message: userMsg,
        history: historyList,
      );

      messages.add(ChatMessage(role: 'assistant', content: reply));
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
    }
  }

  @action
  void clearChat() {
    messages.clear();
    errorMessage = null;
  }
}