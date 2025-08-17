class NativeVideoEvent {
  final int id;
  final String type;
  final int? positionMs;
  final int? durationMs;
  final bool? buffering;

  NativeVideoEvent({
    required this.id,
    required this.type,
    this.positionMs,
    this.durationMs,
    this.buffering,
  });

  factory NativeVideoEvent.fromMap(Map<dynamic, dynamic> m) {
    return NativeVideoEvent(
      id: (m['id'] as num).toInt(),
      type: m['type'] as String,
      positionMs: (m['positionMs'] as num?)?.toInt(),
      durationMs: (m['durationMs'] as num?)?.toInt(),
      buffering: m['buffering'] as bool?,
    );
  }
}
