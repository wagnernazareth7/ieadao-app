import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class IeadaoApp extends StatelessWidget {
  const IeadaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'IEADAO Tsalala',
      theme: AppTheme.light,
      routerConfig: router, // CORREÇÃO: Usando a instância global do GoRouter
      debugShowCheckedModeBanner: false,
    );
  }
}
