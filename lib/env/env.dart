import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env")
abstract class Env {
  @EnviedField(varName: '여기입력')
  static const String apiKey = _Env.apiKey;
}
