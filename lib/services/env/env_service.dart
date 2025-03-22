import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static Future<void> initialize() async {
    await dotenv.load();
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get accountId => dotenv.env['ACCOUNT_ID'] ?? '';
}
