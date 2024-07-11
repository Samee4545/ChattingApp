import 'dart:async';

import 'package:chatapp/models/chatModel.dart';
import 'package:chatapp/services/sharedPrefrences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/FlutterToast.dart';

class DatabaseMethods {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Future<void> addUserInfo(Map<String, dynamic> userInfoMap, String id) async {
    try {
      await _database.child('Users').child(id).set(userInfoMap);
    } catch (e) {
      Utils().toastMessage('Error adding user info: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    List<Map<String, dynamic>> users = [];

    try {
      DatabaseEvent snapshotEvent = await _database
          .child('Users')
          .orderByChild('username')
          .startAt(query)
          .endAt(query + '\uf8ff')
          .once();

      DataSnapshot snapshot = snapshotEvent.snapshot;

      // Check if snapshot.value is not null and is of type Map<dynamic, dynamic>
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          // Convert each user to a Map and add it to the list
          if (value is Map<dynamic, dynamic>) {
            users.add({...value, 'id': key});
          }
        });
      }
    } catch (e) {
      print('Error searching users: $e');
      Fluttertoast.showToast(
        msg: "Search results: error",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
    }

    return users;
  }

  Stream<dynamic> getUser(String email) {
    return _database
        .child('Users')
        .orderByChild('email')
        .equalTo(email)
        .onValue;
  }

  // In the DatabaseMethods class

  Future<dynamic> SearchByName(String username) async {
    try {
      var result = await _database
          .child('Users')
          .orderByChild('searchKey') // Ensure 'searchKey' field is correct
          .equalTo(username.substring(0, 1).toUpperCase())
          .once();
      // print('Search Result: ${result.snapshot.value}');
      return Future<dynamic>.value(result.snapshot.value);
    } catch (e) {
      Utils().toastMessage('Error searching user: $e');
      throw e;
    }
  }

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    try {
      // Await the result of get() to get the snapshot
      final snapshot =
          await _database.child('ChatRoom').child(chatRoomId).get();
      // Check if snapshot doesn't exist (null)
      if (!snapshot.exists) {
        // If snapshot doesn't exist, create the chat room
        await _database
            .child('ChatRoom')
            .child(chatRoomId)
            .set(chatRoomInfoMap);
      }
    } catch (e) {
      Utils().toastMessage('Error creating chat room: $e');
      throw e;
    }
  }

  Future<void> addMessage(
      String chatRoomId, messageId, Map<String, dynamic> messageMap) async {
    try {
      await _database
          .child('ChatRoom')
          .child(chatRoomId)
          .child('chats')
          .child(messageId)
          .set(messageMap);
    } catch (e) {
      Utils().toastMessage('Error adding message: $e');
      throw e;
    }
  }

  Future<void> updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) async {
    try {
      await _database
          .child('ChatRoom')
          .child(chatRoomId)
          .update(lastMessageInfoMap);
    } catch (e) {
      Utils().toastMessage('Error updating last message: $e');
      throw e;
    }
  }

  Future<List<ChatModel>> getChatRoomMessages(String chatRoomId) async {
    final DatabaseReference _ref = FirebaseDatabase.instance
        .reference()
        .child('ChatRoom')
        .child(chatRoomId)
        .child('chats');
    List<ChatModel> products = [];

    DataSnapshot snapshot = (await _ref.once()).snapshot;
    Map<dynamic, dynamic>? values = snapshot.value as Map?;
    if (values != null) {
      values.forEach((key, value) {
        products.add(ChatModel.fromMap(value));
      });
    }

    return products;
  }

//   Future<QuerySnapshot> getTheUserbyUsername(String id) async {
//     DatabaseReference _ref = FirebaseDatabase.instance
//         .reference()
//         .child('Users')
//         .where('username', isEqualTo: id)
//         .get();
//   }
// }
  Future<dynamic> getTheUserInfo(String username) async {
    try {
      var result = await _database
          .child('Users')
          .child('username') // Ensure 'searchKey' field is correct
          .equalTo(username.toUpperCase())
          .once();
      // print('Search Result: ${result.snapshot.value}');
      return Future<dynamic>.value(result.snapshot.value);
    } catch (e) {
      Utils().toastMessage('Error searching user: $e');
      throw e;
    }
  }

  Future<Stream<dynamic>> getChatRooms() async {
    String? myUsername = await sharedPrefrenceHelper().getUserName();
    try {
      var data = _database
          .child('ChatRoom')
          .orderByChild('time')
          .orderByChild('users')
          .equalTo(myUsername!.toUpperCase())
          .onValue;
      return data;
    } catch (e) {
      Utils().toastMessage('Error searching user: $e');
      throw e;
    }
  }
}
