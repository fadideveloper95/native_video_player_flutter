import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeVideoViewWidget extends StatefulWidget {
  final int id;
  final String url;
  final Function(int, String) onViewCreated;

  const NativeVideoViewWidget({
    super.key,
    required this.id,
    required this.url,
    required this.onViewCreated,
  });

  @override
  State<NativeVideoViewWidget> createState() => _NativeVideoViewWidgetState();
}

class _NativeVideoViewWidgetState extends State<NativeVideoViewWidget> {
  late StandardMessageCodec standardMessageCodec;
  late Map<String, int> creationParams;

  @override
  void initState() {
    super.initState();
    standardMessageCodec = const StandardMessageCodec();
    creationParams = {'id': widget.id};
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'NativeVideoView',
        onPlatformViewCreated: (_) => widget.onViewCreated(widget.id, widget.url),
        creationParams: creationParams,
        creationParamsCodec: standardMessageCodec,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'NativeVideoView',
        onPlatformViewCreated: (_) => widget.onViewCreated(widget.id, widget.url),
        creationParams: creationParams,
        creationParamsCodec: standardMessageCodec,
      );
    } else {
      return const Center(child: Text('Unsupported platform'));
    }
  }
}
