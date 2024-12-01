import 'package:dart_openai/dart_openai.dart';
import 'package:mymate/env/env.dart';

class OpenAIService {
  static var apiKey;

  String? selectedCategory;

  Future<String> createModel(String sendMessage) async {
    OpenAI.apiKey = Env.apiKey;
    OpenAI.requestsTimeOut = const Duration(seconds: 60);

    if (selectedCategory == null) {
      final validCategories = ["한식", "중식", "일식", "양식", "야식", "디저트"];
      if (validCategories.contains(sendMessage.trim())) {
        selectedCategory = sendMessage.trim();
        return "좋습니다! $selectedCategory 카테고리에서 추천할 음식을 알려드릴게요. 질문을 입력해주세요!";
      } else {
        return "안녕하세요! 어떤 음식을 추천해드릴까요? 한식, 중식, 일식, 양식, 야식, 디저트 중 하나를 선택해주세요.";
      }
    }

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "You're an AI assistant specialized in recommending food. "
          "You must recommend the food in Korean"
          "Your task is to recommend popular $selectedCategory dishes tailored for Korean preferences.",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          sendMessage,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [
      systemMessage,
      userMessage,
    ];

    try {
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        messages: requestMessages,
        maxTokens: 250,
      );

      String message =
          chatCompletion.choices.first.message.content![0].text.toString();
      return message;
    } catch (error) {
      return "오류가 발생했습니다: $error";
    }
  }

  void resetCategory() {
    selectedCategory = null;
  }
}
