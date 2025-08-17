package com.example.native_video_player

import io.flutter.plugin.common.MethodChannel

object NativeVideoRegistry {
    private val views = mutableMapOf<Int, NativeVideoView>()
    fun put(id: Int, view: NativeVideoView) { views[id] = view }
    fun get(id: Int): NativeVideoView? = views[id]
    fun remove(id: Int) { views.remove(id) }
}

object NativeVideoEvents {
    var channel: MethodChannel? = null
    fun emit(method: String = "event", args: Map<String, Any?>) {
        channel?.invokeMethod(method, args)
    }
}
