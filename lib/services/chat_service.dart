import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<void> sendMessage(
    String currentUser,
    String chatRoomId,
    String receiverId,
    String message,
    String messageType, // Add message type parameter
    {
    String? imageUrl,
  } // Add imageUrl as an optional parameter
      ) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatRoomId);

      // Check if the chat data has been initialized
      final chatData = await chatRef.get();

      // Add the message to the 'messages' subcollection with lastMessageStatus
      final newMessageRef = await chatRef.collection('messages').add({
        'senderId': currentUser,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'lastMessageStatus': 'Delivered',
        'type': messageType, // Set the message type
        'imageUrl': imageUrl, // Set imageUrl if it's an image message
      });

      if (!chatData.exists) {
        // Initialize chat data if it doesn't exist
        await chatRef.set({
          'users': [currentUser, receiverId],
          'senderId': currentUser,
          'receiverId': receiverId,
          'chatRoomId': chatRoomId,
          'isRequested': 'pending',
          'unreadCountFrom': 0,
          'unreadCountTo': 1,
          'lastMessage': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Increment the unreadCount for the receiver
      if (currentUser == chatData['senderId']) {
        await chatRef.update({
          'unreadCountTo': FieldValue.increment(1),
        });
      } else {
        await chatRef.update({
          'unreadCountFrom': FieldValue.increment(1),
        });
      }

      // Update the lastMessage for the chat in the 'chats' collection
      await chatRef.update({
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Future<void> sendAdminMessage(
    String currentUser,
    String chatRoomId,
    String receiverId,
    String message,
    String messageType, // Add message type parameter
    {
    String? imageUrl,
  } // Add imageUrl as an optional parameter
      ) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatRoomId);

      // Check if the chat data has been initialized
      final chatData = await chatRef.get();

      // Add the message to the 'messages' subcollection with lastMessageStatus
      final newMessageRef = await chatRef.collection('messages').add({
        'senderId': currentUser,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'lastMessageStatus': 'Delivered',
        'type': messageType, // Set the message type
        'imageUrl': imageUrl, // Set imageUrl if it's an image message
      });

      if (!chatData.exists) {
        // Initialize chat data if it doesn't exist
        await chatRef.set({
          'users': [currentUser, receiverId],
          'senderId': currentUser,
          'receiverId': receiverId,
          'chatRoomId': chatRoomId,
          'isRequested': 'accepted',
          'unreadCountFrom': 0,
          'unreadCountTo': 1,
          'lastMessage': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Increment the unreadCount for the receiver
      if (currentUser == chatData['senderId']) {
        await chatRef.update({
          'unreadCountTo': FieldValue.increment(1),
        });
      } else {
        await chatRef.update({
          'unreadCountFrom': FieldValue.increment(1),
        });
      }

      // Update the lastMessage for the chat in the 'chats' collection
      await chatRef.update({
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Future<String> uploadImage(
      String userId, String imagePath, String chatRoomId) async {
    try {
      // Generate a unique filename for the image based on timestamp
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Reference to the Firebase Storage bucket
      final storageReference =
          _storage.ref().child('chat_images/$chatRoomId/$fileName');

      // Upload the image to Firebase Storage
      final uploadTask = await storageReference.putFile(File(imagePath));

      // Get the URL of the uploaded image
      final imageUrl = await storageReference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return ''; // Return an empty string or handle error as needed
    }
  }

  Future<void> markLatestMessageAsSeen(
      String chatRoomId, String currentUser) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatRoomId);

      // Get the latest message based on the timestamp
      final latestMessage = await chatRef
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get()
          .then((querySnapshot) => querySnapshot.docs.firstOrNull);

      if (latestMessage != null) {
        // Check if the current user is the receiver
        final String receiverId = latestMessage['receiverId'];

        if (currentUser == receiverId) {
          // Update the lastMessageStatus for the latest message in the subcollection
          await latestMessage.reference.update({
            'lastMessageStatus': 'Seen',
          });
        }
      }
    } catch (e) {
      print("Error marking latest message as seen: $e");
    }
  }

  Future<void> resetUnreadCount(String chatRoomId, String currentUser) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatRoomId);

      // Fetch chat data to identify users
      final chatData = await chatRef.get();

      if (chatData.exists) {
        final List<dynamic> users = chatData['users'];

        if (users.contains(currentUser)) {
          // If the current user is part of the chat, update the corresponding count to 0
          if (currentUser == chatData['receiverId']) {
            await chatRef.update({'unreadCountTo': 0});
          } else if (currentUser == chatData['senderId']) {
            await chatRef.update({'unreadCountFrom': 0});
          }
        }
      }
    } catch (e) {
      print('Error resetting unreadCount: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserInfo(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnapshot = await userRef.get();

    return userSnapshot.data() ?? {};
  }

  Future<String> getChatRoomId(String senderId, String receiverId) async {
    // Sort user IDs to ensure consistency in chat room creation
    List<String> userIds = [senderId, receiverId]..sort();

    return "${userIds[0]}_${userIds[1]}";
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessages(
      String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> acceptRequest(String chatRoomId) async {
    try {
      // Get the reference to the chat document
      final chatRef =
          FirebaseFirestore.instance.collection('chats').doc(chatRoomId);

      // Update the 'isRequested' field to 'accepted'
      await chatRef.update({
        'isRequested': 'accepted',
      });

      print('Request accepted successfully.');
    } catch (e) {
      print('Error accepting request: $e');
      // Handle error as needed
    }
  }

  Future<void> declineRequest(String chatRoomId) async {
    try {
      // Get the reference to the chat document
      final chatRef =
          FirebaseFirestore.instance.collection('chats').doc(chatRoomId);

      // Update the 'isRequested' field to 'accepted'
      await chatRef.update({
        'isRequested': 'declined',
      });

      print('Request accepted successfully.');
    } catch (e) {
      print('Error accepting request: $e');
      // Handle error as needed
    }
  }

  Future<bool> checkIsReceiver(String currentUserId, String receiverId) async {
    try {
      final chatRoomId = await getChatRoomId(currentUserId, receiverId);
      final chatData = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .get();

      return chatData['receiverId'] == currentUserId;
    } catch (e) {
      print('Error checking if the current user is the receiver: $e');
      return false;
    }
  }

  Future<String> checkIsRequested(String chatRoomId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('chatRooms').doc(chatRoomId).get();

      final Map<String, dynamic>? data = docSnapshot.data();
      final String isRequested = data?['isRequested'] ?? false;

      return isRequested;
    } catch (error) {
      print('Error checking if the request is declined: $error');
      return '';
    }
  }

  Future<String> isChatRequestAccepted(String chatRoomId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('chats').doc(chatRoomId).get();

      final Map<String, dynamic>? data = docSnapshot.data();
      final String isRequested = data?['isRequested'] ?? '';

      return isRequested;
    } catch (error) {
      print('Error checking chat request status: $error');
      return '';
    }
  }

  Future<bool> checkIsRequestedAccepted(
      String otherUserId, String currentUserId) async {
    try {
      // Construct the chat room ID
      String chatRoomId = await getChatRoomId(currentUserId, otherUserId);

      // Retrieve the chat document from Firestore
      DocumentSnapshot<Map<String, dynamic>> chatDoc = await FirebaseFirestore
          .instance
          .collection('chats')
          .doc(chatRoomId)
          .get();

      // Check if the chat document exists and the request status is "accepted"
      return chatDoc.exists && chatDoc['isRequested'] == 'accepted';
    } catch (error) {
      print('Error checking chat request status: $error');
      return false;
    }
  }
}
