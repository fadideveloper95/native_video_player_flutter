package com.example.native_video_player

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeVideoViewFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE),
    MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "native_video/channel")

    init {
        channel.setMethodCallHandler(this)
        NativeVideoEvents.channel = channel
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        val logicalId = (params?.get("id") as? Int) ?: viewId
        val view = NativeVideoView(context)
        view.logicalId = logicalId
        NativeVideoRegistry.put(logicalId, view)
        return view
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val id = (call.argument<Int>("id"))
        val view = id?.let { NativeVideoRegistry.get(it) }
        when (call.method) {
            "register" -> {
                val url = call.argument<String>("url")
                val autoPlay = call.argument<Boolean>("autoPlay") ?: false
                val loop = call.argument<Boolean>("loop") ?: false
                val volume = call.argument<Double>("volume") ?: 1.0
                val muted = call.argument<Boolean>("muted") ?: false
                if (view != null && url != null) {
                    view.prepare(url, autoPlay, loop, volume.toFloat(), muted)
                    result.success(null)
                } else result.error("VIEW_OR_URL_NULL", "View or url is null", null)
            }
            "play" -> { view?.play(); result.success(null) }
            "pause" -> { view?.pause(); result.success(null) }
            "seekTo" -> {
                val ms = call.argument<Int>("ms")?.toLong() ?: 0L
                view?.seekTo(ms); result.success(null)
            }
            "setVolume" -> {
                val vol = call.argument<Double>("volume")?.toFloat() ?: 1f
                view?.setVolume(vol); result.success(null)
            }
            "setMuted" -> {
                val muted = call.argument<Boolean>("muted") ?: false
                view?.setMuted(muted); result.success(null)
            }
            "dispose" -> {
                view?.dispose()
                if (id != null) NativeVideoRegistry.remove(id)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
