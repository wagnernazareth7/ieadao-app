import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'env.dart';

class AppConfig {
  static Future<void> initialize() async {
    // 1. Carrega variáveis de ambiente (.env)
    await dotenv.load(fileName: ".env");

    // 2. Inicializa Firebase
    await Firebase.initializeApp();

    // 3. Inicializa Supabase (Chat e Realtime Stats)
    if (Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
    }
  }
}
