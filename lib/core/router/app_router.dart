import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ieadao/core/auth/auth_gate.dart';
import 'package:ieadao/features/auth/register/register_page.dart'; // NOVO IMPORT
import 'package:ieadao/features/membros/pages/membros_list_page.dart';
import 'package:ieadao/features/membros/pages/membro_form_page.dart';
import 'package:ieadao/features/membros/pages/membro_detalhes_page.dart';
import 'package:ieadao/features/profile/profile_page.dart';
import 'package:ieadao/features/donations/pages/donations_admin_dashboard_page.dart';
import 'package:ieadao/features/donations/donation_page.dart'; 
import 'package:ieadao/features/evento/evento_list_page.dart';
import 'package:ieadao/features/evento/evento_detalhe_page.dart';
import 'package:ieadao/features/evento/evento_form_page.dart';
import 'package:ieadao/features/ebd/pages/ebd_admin_dashboard_page.dart';
import 'package:ieadao/features/ebd/pages/ebd_class_detail_page.dart';
import 'package:ieadao/features/ebd/pages/ebd_class_list_page.dart';
import 'package:ieadao/features/ebd/pages/ebd_form_page.dart';
import 'package:ieadao/features/escalas/pages/escala_admin_page.dart';
import 'package:ieadao/features/louvor/pages/setlist_editor_page.dart';
import 'package:ieadao/features/chat/chat_page.dart';
import 'package:ieadao/features/louvor/pages/music_detail_page.dart';
import 'package:ieadao/features/louvor/pages/order_of_service_page.dart';
import 'package:ieadao/features/prayer/pages/prayer_page.dart';
import 'package:ieadao/features/journal/pages/journal_page.dart';
import 'package:ieadao/features/bible/pages/bible_page.dart';
import 'package:ieadao/features/ai_assistant/pages/ai_chat_page.dart';
import 'package:ieadao/features/notices/notices_page.dart';
import 'package:ieadao/features/library/pages/library_page.dart'; 
import 'package:ieadao/features/admin/audit_logs_page.dart';
import 'package:ieadao/features/reports/reports_dashboard_page.dart';
import 'package:ieadao/features/inventory/pages/inventory_page.dart';
import 'package:ieadao/features/membros/pages/spiritual_family_admin_page.dart';
import 'package:ieadao/core/models/music_model.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    
    // --- AUTENTICAÇÃO ---
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()), // ROTA ADICIONADA

    // --- ROTAS DA COMUNIDADE (MEMBROS) ---
    GoRoute(path: '/ebd', builder: (context, state) => const EbdClassListPage()),
    GoRoute(path: '/oracao', builder: (context, state) => const PrayerPage()),
    GoRoute(path: '/diario', builder: (context, state) => const JournalPage()),
    GoRoute(path: '/bible', builder: (context, state) => const BiblePage()),
    GoRoute(path: '/ia-assistant', builder: (context, state) => const AiChatPage()),
    GoRoute(path: '/comunicados', builder: (context, state) => const NoticesPage()),
    GoRoute(path: '/donations', builder: (context, state) => const DonationPage()),
    GoRoute(path: '/biblioteca', builder: (context, state) => const LibraryPage()),

    // --- ROTAS ADMINISTRATIVAS ---
    GoRoute(path: '/membros', builder: (context, state) => const MembrosListPage()),
    GoRoute(path: '/membros/novo', builder: (context, state) => const MembroFormPage()),
    GoRoute(path: '/membros/:id', builder: (context, state) => MembroDetalhesPage(membroId: state.pathParameters['id']!)),
    GoRoute(path: '/membros/:id/edit', builder: (context, state) => MembroFormPage(membro: state.extra as dynamic)),
    GoRoute(path: '/donations-admin', builder: (context, state) => const DonationsAdminDashboardPage()),
    GoRoute(path: '/discipulado', builder: (context, state) => const SpiritualFamilyAdminPage()),
    GoRoute(path: '/audit', builder: (context, state) => const AuditLogsPage()),
    GoRoute(path: '/reports', builder: (context, state) => const ReportsDashboardPage()),
    GoRoute(path: '/inventario', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/biblioteca-admin', builder: (context, state) => const LibraryPage()),
    
    // --- AGENDA E ESCALAS ---
    GoRoute(path: '/agenda', builder: (context, state) => const EventoListPage()),
    GoRoute(path: '/agenda/:id', builder: (context, state) => EventoDetalhePage(eventoId: state.pathParameters['id']!)),
    GoRoute(path: '/evento_form', builder: (context, state) => EventoFormPage(evento: state.extra as dynamic)),
    GoRoute(path: '/escala-admin', builder: (context, state) => const EscalaAdminPage()),

    // --- EBD GESTÃO ---
    GoRoute(path: '/ebd-admin', builder: (context, state) => const EbdAdminDashboardPage()),
    GoRoute(path: '/ebd/novo', builder: (context, state) => const EbdFormPage()),
    GoRoute(path: '/ebd/edit', builder: (context, state) => EbdFormPage(turma: state.extra as dynamic)),
    
    // --- LITURGIA E LOUVOR ---
    GoRoute(path: '/setlists/editor', builder: (context, state) => const SetlistEditorPage()),
    GoRoute(path: '/setlists/editor/:id', builder: (context, state) => SetlistEditorPage(setlistId: state.pathParameters['id']!)),
    GoRoute(
      path: '/chat/:channel/:title',
      builder: (context, state) => ChatPage(
        channel: state.pathParameters['channel']!,
        channelName: state.pathParameters['title']!,
      ),
    ),
    GoRoute(path: '/louvor/musica', builder: (context, state) => MusicDetailPage(music: state.extra as Music)),
    GoRoute(path: '/culto/roteiro', builder: (context, state) => const OrderOfServicePage()),
  ],
);
