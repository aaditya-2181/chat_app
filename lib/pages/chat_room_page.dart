import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/massage_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  // Define variables and functions
  TextEditingController massageController = TextEditingController();

  void sendMassage() async {
    String msg = massageController.text.trim();
    massageController.clear();
    if (msg != "") {
      // send massage
      MassageModel newMassageModel = MassageModel(
          massageId: uuid.v1(),
          sender: widget.userModel.uid,
          text: msg,
          createdOn: DateTime.now(),
          seen: false);
      // massages store in firebase firestore 'massages' collection
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatRoomId)
          .collection("massages")
          .doc(newMassageModel.massageId)
          .set(newMassageModel.toMap());
      log("massage send");

      // change last massage variable value
      widget.chatroom.lastMassage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatRoomId)
          .set(widget.chatroom.toMap());
    }
  }

// End variables and functions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // User Details and profile pic
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilePic.toString()),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(widget.targetUser.userName.toString())
          ],
        ),
      ),

      // Starting Chat massages
      body: SafeArea(
          child: Column(
        children: [
          // this is where chats will go
          Expanded(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .doc(widget.chatroom.chatRoomId)
                .collection("massages")
                .orderBy("createdOn", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                  return ListView.builder(
                      reverse: true,
                      itemCount: dataSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        MassageModel currentMassage = MassageModel.fromMap(
                            dataSnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        return Row(
                          mainAxisAlignment:
                              (currentMassage.sender == widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: (currentMassage.sender ==
                                            widget.userModel.uid)
                                        ? Colors.grey
                                        : Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  currentMassage.text.toString(),
                                  style: const TextStyle(color: Colors.white),
                                )),
                          ],
                        );
                      });
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                        "An error occured! Please chaeck your internet connection"),
                  );
                } else {
                  return const Center(
                    child: Text("Say hi"),
                  );
                }
              } else {
                return const CircularProgressIndicator();
              }
            },
          )),

          // bottom textfield and others
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.grey[300],
            child: Row(
              children: [
                Flexible(
                    child: TextField(
                  controller: massageController,
                  maxLines: null,
                  decoration: const InputDecoration(hintText: "Enter massage"),
                )),
                IconButton(
                    onPressed: () {
                      sendMassage();
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blueAccent,
                    )),
              ],
            ),
          )
        ],
      )),
    );
  }
}
