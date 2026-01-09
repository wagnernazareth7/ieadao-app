import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../theme/app_colors.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final String title;

  const AudioPlayerWidget({super.key, required this.url, required this.title});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(widget.url);
    } catch (e) {
      debugPrint("Erro ao carregar áudio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  
                  if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                    return const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 2));
                  } else if (playing != true) {
                    return IconButton(
                      icon: const Icon(Icons.play_circle_fill, size: 48, color: AppColors.primary),
                      onPressed: _player.play,
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.pause_circle_filled, size: 48, color: AppColors.primary),
                      onPressed: _player.pause,
                    );
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text('Ministração Gravada', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<Duration?>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              return ProgressBar(
                progress: snapshot.data ?? Duration.zero,
                buffered: _player.bufferedPosition,
                total: _player.duration ?? Duration.zero,
                onSeek: _player.seek,
                progressBarColor: AppColors.primary,
                baseBarColor: Colors.grey.shade300,
                bufferedBarColor: AppColors.primary.withOpacity(0.2),
                thumbColor: AppColors.primary,
                timeLabelTextStyle: const TextStyle(fontSize: 10, color: Colors.grey),
              );
            },
          ),
        ],
      ),
    );
  }
}
