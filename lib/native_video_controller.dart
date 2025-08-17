import 'package:flutter/services.dart';
import 'package:flutter_native_video_pageview/models/native_video_event.dart';

typedef NativeEventHandler = void Function(NativeVideoEvent event);

class NativeVideoController {
  final int id;

  static const MethodChannel channel = MethodChannel('native_video/channel');
  static final Map<int, NativeEventHandler?> eventHandlers = {};
  static Future<dynamic> handleNativeCallback(MethodCall call) async {
    if (call.method == 'event') {
      final map = Map<dynamic, dynamic>.from(call.arguments as Map);
      final evt = NativeVideoEvent.fromMap(map);
      eventHandlers[evt.id]?.call(evt);
    }
    return null;
  }

  static bool handlerIsSet = false;

  NativeVideoController({required this.id, NativeEventHandler? onEvent}) {
    eventHandlers[id] = onEvent;
    if (!handlerIsSet) {
      channel.setMethodCallHandler(handleNativeCallback);
      handlerIsSet = true;
    }
  }

  void disposeController() {
    eventHandlers.remove(id);
  }

  Future<void> register({
    required String url,
    bool autoPlay = false,
    bool loop = false,
    double volume = 1.0,
    bool muted = false,
  }) async {
    await channel.invokeMethod('register', {
      'id': id,
      'url': url,
      'autoPlay': autoPlay,
      'loop': loop,
      'volume': volume,
      'muted': muted,
    });
  }

  Future<void> play() => channel.invokeMethod('play', {'id': id});

  Future<void> pause() => channel.invokeMethod('pause', {'id': id});

  Future<void> seekTo(Duration position) => channel.invokeMethod('seekTo', {
        'id': id,
        'ms': position.inMilliseconds,
      });

  Future<void> setVolume(double volume) => channel.invokeMethod('setVolume', {
        'id': id,
        'volume': volume,
      });

  Future<void> setMuted(bool muted) => channel.invokeMethod('setMuted', {
        'id': id,
        'muted': muted,
      });

  Future<void> dispose() => channel.invokeMethod('dispose', {'id': id});
}
