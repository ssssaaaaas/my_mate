import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env") // .env 파일에서 환경 변수를 로드
abstract class Env {
  @EnviedField(varName: 'OPEN_AI_API_KEY') // .env 파일에 있는 OPEN_AI_API_KEY를 참조
  static const String apiKey = _Env.apiKey; // _Env 클래스에서 apiKey를 가져옴
}
