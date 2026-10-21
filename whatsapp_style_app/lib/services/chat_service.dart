import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String buildChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> createChatIfNeeded(String otherUid) async {
    final currentUid = _auth.currentUser!.uid;
    final chatId = buildChatId(currentUid, otherUid);

    final doc = await _db.collection('chats').doc(chatId).get();
    if (!doc.exists) {
      await _db.collection('chats').doc(chatId).set({
        'participants': [currentUid, otherUid],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageSenderId': '',
      });
    }
  }

  Stream<QuerySnapshot> getMessages(String otherUid) {
    final currentUid = _auth.currentUser!.uid;
    final chatId = buildChatId(currentUid, otherUid);

    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String otherUid, String text) async {
    final currentUid = _auth.currentUser!.uid;
    final chatId = buildChatId(currentUid, otherUid);

    if (text.trim().isEmpty) return;

    final msg = {
      'senderId': currentUid,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'text',
    };

    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(msg);

    await _db.collection('chats').doc(chatId).set({
      'participants': [currentUid, otherUid],
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': text.trim(),
      'lastMessageSenderId': currentUid,
    }, SetOptions(merge: true));
  }
}
