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
  String? nickName; // 닉네임 저장
  String? title;

  @override
  void initState() {
    super.initState();
    getCategoryTitle();
    getCurrentUser();
  }

  Future<void> getCategoryTitle() async {
    try {
      // widget.category는 컬렉션 이름으로 가정하고,
      // widget.id는 해당 문서의 ID입니다.
      final docSnapshot = await FirebaseFirestore.instance
          .collection(widget.category) // widget.category 컬렉션
          .doc(widget.id) // widget.id는 문서 ID
          .get();

      if (docSnapshot.exists) {
        setState(() {
          // title 필드를 가져와서 title 변수에 저장
          title = docSnapshot.data()?['title'];
        });
      } else {
        print("Document does not exist.");
      }
    } catch (e) {
      print("Error getting category title: $e");
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
        // 닉네임 가져오기
        final userDoc = await FirebaseFirestore.instance
            .collection('users') // 사용자 정보를 저장한 컬렉션 이름
            .doc(user.uid) // 로그인한 사용자의 UID로 문서 찾기
            .get();

        if (userDoc.exists) {
          setState(() {
            nickName = userDoc.data()?['nickName']; // Firestore에서 닉네임 가져오기
          });
        } else {
          print("User document does not exist.");
        }
      }
    } catch (e) {
      print("Error getting current user: $e");
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
        'sender': nickName, // 닉네임 저장
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            title ?? 'Chat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.pin_drop_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
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
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No messages yet."));
                    }
                    final chatDocs = snapshot.data!.docs;
                    return ListView.builder(
                      reverse: true,
                      itemCount: chatDocs.length,
                      itemBuilder: (ctx, index) {
                        bool isMe =
                            chatDocs[index]['sender'] == nickName; // 닉네임으로 비교
                        return Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 17),
                              child: Text(
                                chatDocs[index]['sender'], // 닉네임 표시
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
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  margin: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.grey[100]
                                        : Color(0XFFD76F69),
                                    borderRadius: isMe
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(14),
                                            topRight: Radius.circular(14),
                                            bottomLeft: Radius.circular(14),
                                          )
                                        : BorderRadius.only(
                                            topLeft: Radius.circular(14),
                                            topRight: Radius.circular(14),
                                            bottomRight: Radius.circular(14),
                                          ),
                                  ),
                                  child: Text(
                                    chatDocs[index]['text'],
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
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
              SizedBox(height: 20),
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
                      color: Color(0XFFF2F3F5),
                    ),
                    child: TextField(
                      controller: _controller,
                      cursorColor: Color(0XFFC5524C),
                      decoration: InputDecoration(
                        hintText: 'Send a message...',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Pretendard Variable",
                          color: Color(0XFF4E5968),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            size: 30,
                            color: Color(0XFF4E5968),
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
        ));
  }
}
