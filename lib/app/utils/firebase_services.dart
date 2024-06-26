import 'package:chat_app/app/data/chat_response.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal() {
    _initializeChatCollection();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference<Chat> chatCollection;

  void _initializeChatCollection() {
    chatCollection = _firestore.collection('chats').withConverter<Chat>(
          fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        );
  }
}
