import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String id;
  final String category;

  ChatScreen({required this.id, required this.category});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String? nickName;
  String? title;
  int maxParticipants = 10;
  bool isRoomFull = false;
  bool _isDecrementing = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getCategoryTitle();
    checkRoomCapacity();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            nickName = userDoc.data()?['nickName'];
          });
        } else {
          print("User document does not exist.");
        }
      }
    } catch (e) {
      print("Error getting current user: $e");
    }
  }

  Future<void> getCategoryTitle() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(widget.category)
          .doc(widget.id)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          title = docSnapshot.data()?['title'];
        });
      } else {
        print("Document does not exist.");
      }
    } catch (e) {
      print("Error getting category title: $e");
    }
  }

  Future<void> checkRoomCapacity() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(widget.category)
          .doc(widget.id)
          .get();

      if (docSnapshot.exists) {
        int currentCount = docSnapshot.data()?['currentCount'] ?? 0;
        if (currentCount >= maxParticipants) {
          setState(() {
            isRoomFull = true;
          });
        }
      }
    } catch (e) {
      print("Error checking room capacity: $e");
    }
  }

  Future<void> decrementParticipantCount() async {
    if (_isDecrementing) return;
    _isDecrementing = true;

    try {
      await FirebaseFirestore.instance
          .collection(widget.category)
          .doc(widget.id)
          .update({'currentCount': FieldValue.increment(-1)});
    } catch (e) {
      print("Error decrementing participant count: $e");
    } finally {
      _isDecrementing = false;
    }
  }

  void _sendMessage() {
    _controller.text = _controller.text.trim();
    if (_controller.text.isNotEmpty &&
        loggedInUser != null &&
        nickName != null) {
      FirebaseFirestore.instance
          .collection(widget.category)
          .doc(widget.id)
          .collection('messages')
          .add({
        'text': _controller.text,
        'sender': nickName,
        'timestamp': Timestamp.now(),
      });
      _controller.clear();
    } else if (loggedInUser == null) {
      print("User is not logged in.");
    } else if (nickName == null) {
      print("NickName is not available.");
    }
  }

  @override
  void dispose() {
    decrementParticipantCount();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isRoomFull) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Room Full'),
        ),
        body: const Center(
          child: Text(
            'This room is full. Please try again later.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              title ?? 'Chat',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0XFFFFBAB6)],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(widget.category)
                        .doc(widget.id)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No messages yet."));
                      }
                      final chatDocs = snapshot.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        itemCount: chatDocs.length,
                        itemBuilder: (ctx, index) {
                          bool isMe = chatDocs[index]['sender'] == nickName;
                          return Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  chatDocs[index]['sender'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.white : Colors.white,
                                      borderRadius: isMe
                                          ? const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14),
                                              bottomLeft: Radius.circular(14),
                                            )
                                          : const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14),
                                              bottomRight: Radius.circular(14),
                                            ),
                                    ),
                                    child: Text(
                                      chatDocs[index]['text'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0XFFF2F3F5),
                      ),
                      child: TextField(
                        controller: _controller,
                        cursorColor: const Color(0XFFC5524C),
                        decoration: InputDecoration(
                          hintText: 'Send a message...',
                          hintStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Pretendard Variable",
                            color: Color(0XFF4E5968),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              size: 30,
                              color: Color(0XFFE65951),
                            ),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          )),
    );
  }
}
