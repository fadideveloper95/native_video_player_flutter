import 'package:flutter/material.dart';

class BottomControlsWidget extends StatefulWidget {
  final bool isMuted;
  final (int, int)? progressTuple;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final Function(Duration) onSeekRelative;
  final VoidCallback onToggleMute;

  const BottomControlsWidget({
    super.key,
    required this.isMuted,
    this.progressTuple,
    required this.onPlay,
    required this.onPause,
    required this.onSeekRelative,
    required this.onToggleMute,
  });

  @override
  State<BottomControlsWidget> createState() => _BottomControlsWidgetState();
}

class _BottomControlsWidgetState extends State<BottomControlsWidget> {
  @override
  Widget build(BuildContext context) {
    final position = widget.progressTuple?.$1 ?? 0;
    final duration = widget.progressTuple?.$2 ?? 1;
    final progress = duration == 0 ? 0.0 : position / duration;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onPlay,
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: widget.onPause,
                  icon: const Icon(
                    Icons.pause,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => widget.onSeekRelative(const Duration(seconds: -10)),
                  icon: const Icon(
                    Icons.replay_10,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => widget.onSeekRelative(const Duration(seconds: 10)),
                  icon: const Icon(
                    Icons.forward_10,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${Duration(milliseconds: position).toString().split('.').first} / ${Duration(milliseconds: duration).toString().split('.').first}',
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: widget.onToggleMute,
                  icon: Icon(
                    widget.isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
