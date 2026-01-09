import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app.dart'; // Importa o widget principal
import 'core/config/env.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: ".env");

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // CONFIGURAÇÃO DE CACHE ILIMITADO PARA OPERAÇÃO OFFLINE
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Inicializa o Supabase para futuras integrações (IA Luz, etc)
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    // Garante que as datas sejam formatadas para Moçambique/Brasil
    await initializeDateFormatting('pt_BR', null);

    // INICIALIZAÇÃO SÉNIOR: Usando ProviderScope para o Riverpod
    runApp(const ProviderScope(child: IeadaoApp()));

  } catch (e) {
    debugPrint('FALHA CRÍTICA NA INICIALIZAÇÃO: $e');
    // Em caso de falha, exibe uma tela de erro segura
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Erro ao iniciar a aplicação.')))));
  }
}
