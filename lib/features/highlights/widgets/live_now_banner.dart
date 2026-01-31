import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/live_stream_service.dart';
import '../../../core/theme/app_colors.dart';

class LiveNowBanner extends StatefulWidget {
  const LiveNowBanner({super.key});

  @override
  State<LiveNowBanner> createState() => _LiveNowBannerState();
}

class _LiveNowBannerState extends State<LiveNowBanner> {
  final _service = LiveStreamService();
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {}); // Força rebuild para atualizar o tempo
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LiveStream>(
      stream: _service.watchLiveStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final live = snapshot.data!;

        // Caso 1: Live está AO VIVO agora
        if (live.isLive) return _buildLiveActiveBanner(live);

        // Caso 2: Live está AGENDADA para o futuro
        if (live.scheduledStartTime != null && live.scheduledStartTime!.isAfter(DateTime.now())) {
          _timeLeft = live.scheduledStartTime!.difference(DateTime.now());
          return _buildScheduledBanner(live, _timeLeft);
        }

        // Caso 3: Nada acontecendo
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLiveActiveBanner(LiveStream live) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.redAccent, Color(0xFFB91C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              if (live.url != null) {
                final url = Uri.parse(live.url!);
                if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const _LiveIndicator(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ESTAMOS AO VIVO!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
                        Text(live.title ?? 'Culto de Adoração', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
          _buildReactionArea(live),
        ],
      ),
    );
  }

  Widget _buildScheduledBanner(LiveStream live, Duration timeLeft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.timer_outlined, color: Colors.orangeAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CULTO AGENDADO', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
                Text(_formatDuration(timeLeft), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              ],
            ),
          ),
          const Text('EM BREVE', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReactionArea(LiveStream live) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
      child: Row(
        children: [
          _ReactionButton(label: 'Amém', count: live.amemCount, icon: Icons.front_hand, onTap: () => _service.sendAmem()),
          const SizedBox(width: 16),
          _ReactionButton(label: 'Glória', count: live.heartCount, icon: Icons.favorite, onTap: () => _service.sendHeart()),
          const Spacer(),
          const Text('Participe da Live', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String label; final int count; final IconData icon; final VoidCallback onTap;
  const _ReactionButton({required this.label, required this.count, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Row(children: [Icon(icon, color: Colors.white, size: 14), const SizedBox(width: 4), Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)), const SizedBox(width: 4), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10))]));
}

class _LiveIndicator extends StatefulWidget {
  const _LiveIndicator();
  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _controller, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: const Text('LIVE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 9))));
}
