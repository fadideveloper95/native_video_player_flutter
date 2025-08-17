import 'package:flutter/material.dart';
import 'package:flutter_native_video_pageview/widgets/native_video_view_widget.dart';

class VideoPageWidget extends StatefulWidget {
  final int index;
  final String url;
  final bool isLoading;
  final Function(int, String) onViewCreated;

  const VideoPageWidget({
    super.key,
    required this.index,
    required this.url,
    required this.isLoading,
    required this.onViewCreated,
  });

  @override
  State<VideoPageWidget> createState() => _VideoPageWidgetState();
}

class _VideoPageWidgetState extends State<VideoPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        NativeVideoViewWidget(
          id: widget.index,
          url: widget.url,
          onViewCreated: widget.onViewCreated,
        ),
        if (widget.isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
