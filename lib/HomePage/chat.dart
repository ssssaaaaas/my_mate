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

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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

  Future<void> _decrementCurrentCount() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection(widget.category).doc(widget.id);

      await docRef.update({
        'currentCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print("Error decrementing currentCount: $e");
    }
  }

  @override
  void dispose() {
    // 화면이 닫힐 때 currentCount 감소
    _decrementCurrentCount();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            chatDocs[index]['sender'], // 닉네임 표시
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
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
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.grey[300] : Colors.grey[500],
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
                                style: TextStyle(fontSize: 16),
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
