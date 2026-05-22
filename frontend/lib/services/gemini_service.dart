import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;

  GenerativeModel get _gemini {
    _model ??= GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
    );

    return _model!;
  }

  Future<String> generatePlantDiseaseInfo({
    required String plantName,
    required String diseaseName,
  }) async {

    final key =
        dotenv.env['GEMINI_API_KEY'];

    if (key == null || key.isEmpty) {
      throw Exception(
        "GEMINI_API_KEY не найден"
      );
    }

    final model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: key,
    );

    final prompt = '''
  Ты эксперт по растениям.

  Растение: $plantName
  Болезнь: $diseaseName

  Ответ строго:

  Описание растения:
  ...

  Описание болезни:
  ...

  Симптомы:
  ...

  Причины:
  ...

  Лечение:
  ...

  Профилактика:
  ...
  ''';

    final response =
        await model.generateContent([
      Content.text(prompt),
    ]);

    return response.text ??
        "Пустой ответ Gemini";
  }
}