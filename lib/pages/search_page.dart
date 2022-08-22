import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    // Find the target user form "chatrooms" collection
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Chat room already exist
      log("chatroom already exist");
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoomModel =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatRoomModel;
    } else {
      // Create new chatroom
      log("Chatroom Not exist");
      ChatRoomModel newChatroom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMassage: "",
        participants: {
          widget.userModel.uid!.toString(): true,
          targetUser.uid!.toString(): true,
        },
      );

// Fetching data to firebase firestore database
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatRoomId)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("new chatroom created!");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(labelText: "Email Address"),
            ),
            const SizedBox(
              height: 20,
            ),
            CupertinoButton(
              onPressed: () {
                log(FirebaseAuth.instance.currentUser.toString());
                setState(() {});
              },
              color: Colors.blueAccent,
              child: const Text("Search"),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: searchController.text)
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                    if (dataSnapshot.docs.isNotEmpty) {
                      Map<String, dynamic> userMap =
                          dataSnapshot.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatroomModel =
                              await getChatRoomModel(searchedUser);
                          if (chatroomModel != null) {
                            if (!mounted) return;
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ChatRoomPage(
                                  targetUser: searchedUser,
                                  chatroom: chatroomModel,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser);
                            }));
                          }
                        },
                        leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(searchedUser.profilePic!)),
                        title: Text(searchedUser.userName!),
                        subtitle: Text(searchedUser.email!),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                      );
                    } else {
                      return const Text("no result found");
                    }
                  } else if (snapshot.hasError) {
                    return const Text("An error occured!");
                  } else {
                    return const Text("no result found!");
                  }
                }

                // final else
                else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      )),
    );
  }
}
