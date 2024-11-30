import 'package:flutter/material.dart';
import 'package:mymate/RecommendPage/openai_service.dart';
import 'package:mymate/env/env.dart';

class FoodAIPage extends StatefulWidget {
  const FoodAIPage({Key? key}) : super(key: key);

  @override
  State<FoodAIPage> createState() => _FoodAIPageState();
}

class _FoodAIPageState extends State<FoodAIPage> {
  final TextEditingController _controller = TextEditingController();
  final OpenAIService _openAIService = OpenAIService();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // 디버깅: Env에서 API 키 로드 확인
    print("Loaded API Key: ${Env.apiKey}");
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": userMessage});
      isLoading = true;
    });

    _controller.clear();

    try {
      // 디버깅: 사용자 메시지 확인
      print("User message: $userMessage");

      final aiResponse = await _openAIService.createModel(userMessage);

      // 디버깅: AI 응답 확인
      print("AI Response: $aiResponse");

      setState(() {
        messages.add({"role": "ai", "content": aiResponse});
        isLoading = false;
      });
    } catch (error) {
      // 디버깅: 오류 발생 시 로그 출력
      print("OpenAI API Error: $error");

      setState(() {
        messages.add({"role": "ai", "content": "오류가 발생했습니다. 다시 시도해주세요."});
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 기반 음식 추천'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["role"] == "user";

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child:
                              Icon(Icons.restaurant_menu, color: Colors.white),
                        ),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            message["content"]!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 8.0),
                    ],
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '음식에 대해 알고 싶은 내용을 입력하세요...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
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
