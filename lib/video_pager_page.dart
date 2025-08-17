import 'package:flutter/material.dart';
import 'package:flutter_native_video_pageview/constants.dart';
import 'package:flutter_native_video_pageview/models/native_video_event.dart';
import 'package:flutter_native_video_pageview/native_video_controller.dart';
import 'package:flutter_native_video_pageview/widgets/bottom_controls.dart';
import 'package:flutter_native_video_pageview/widgets/video_page.dart';

class VideoPagerPage extends StatefulWidget {
  const VideoPagerPage({super.key});
  @override
  State<VideoPagerPage> createState() => _VideoPagerPageState();
}

class _VideoPagerPageState extends State<VideoPagerPage> {
  final pageController = PageController();

  final Set<int> createdViewIds = {};
  final Set<int> registeredIds = {};

  final Map<int, NativeVideoController> controllers = {};
  final Map<int, (int posMs, int durMs)> progress = {};
  final Map<int, bool> buffering = {};
  final Map<int, bool> muted = {};

  int currentPage = 0;

  void handleEvent(NativeVideoEvent e) {
    if (!mounted) return;
    switch (e.type) {
      case 'progress':
        final dur = e.durationMs ?? 0;
        final pos = e.positionMs ?? 0;
        setState(() => progress[e.id] = (pos, dur));
        break;
      case 'buffering':
        setState(() => buffering[e.id] = e.buffering ?? false);
        break;
      case 'ready':
        setState(() => buffering[e.id] = false);
        break;
      case 'completed':
        final dur = e.durationMs ?? 0;
        setState(() => progress[e.id] = (dur, dur));
        break;
    }
  }

  void onViewCreated(int id, String url) async {
    createdViewIds.add(id);

    final controller = NativeVideoController(id: id, onEvent: handleEvent);

    controllers[id] = controller;

    await controller.register(
      url: url,
      autoPlay: id == currentPage,
      muted: muted[id] ?? false,
    );

    registeredIds.add(id);
  }

  void onPageChanged(int index) {
    controllers[currentPage]?.pause();

    final Set<int> keepAlive = {index, index - 1, index + 1};

    controllers.keys.where((id) => !keepAlive.contains(id)).toList().forEach((id) {
      controllers[id]?.dispose();
      controllers[id]?.disposeController();
      controllers.remove(id);
      createdViewIds.remove(id);
      registeredIds.remove(id);
      progress.remove(id);
      buffering.remove(id);
      muted.remove(id);
    });

    setState(() => currentPage = index);

    controllers[index]?.play();
  }

  void onToggleMute() {
    final currentlyMuted = muted[currentPage] ?? false;
    muted[currentPage] = !currentlyMuted;
    controllers[currentPage]?.setMuted(!currentlyMuted);
    setState(() {});
  }

  void onSeekRelative(Duration duration) {
    final prog = progress[currentPage];
    if (prog == null) return;
    final next = (prog.$1 + duration.inMilliseconds).clamp(0, prog.$2);
    controllers[currentPage]?.seekTo(Duration(milliseconds: next));
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
      controller.disposeController();
    }
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMuted = muted[currentPage] ?? false;
    final progressTuple = progress[currentPage];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Native Video PageView'),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: pageController,
        allowImplicitScrolling: true,
        onPageChanged: onPageChanged,
        itemCount: urls.length,
        itemBuilder: (context, index) {
          return VideoPageWidget(
            key: ValueKey(index),
            index: index,
            url: urls[index],
            isLoading: buffering[index] ?? false,
            onViewCreated: onViewCreated,
          );
        },
      ),
      bottomNavigationBar: BottomControlsWidget(
        isMuted: isMuted,
        progressTuple: progressTuple,
        onPlay: () => controllers[currentPage]?.play(),
        onPause: () => controllers[currentPage]?.pause(),
        onToggleMute: onToggleMute,
        onSeekRelative: onSeekRelative,
      ),
    );
  }
}
