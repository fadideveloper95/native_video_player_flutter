package com.example.native_video_player

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.Player
import io.flutter.plugin.platform.PlatformView

class NativeVideoView(context: Context) : PlatformView {
    private val playerView = PlayerView(context)
    private var player: ExoPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    private var progressRunnable: Runnable? = null

    var logicalId: Int = -1
    private var mutedFlag = false
    private var unmutedVolume = 1f

    init {
        playerView.useController = false
    }

    fun prepare(url: String, autoPlay: Boolean, loop: Boolean, volume: Float, muted: Boolean) {
        if (player == null) {
            player = ExoPlayer.Builder(playerView.context).build().also { p ->
                playerView.player = p
                p.addListener(object : Player.Listener {
                    override fun onPlaybackStateChanged(state: Int) {
                        when (state) {
                            Player.STATE_BUFFERING -> {
                                NativeVideoEvents.emit("event", mapOf(
                                    "id" to logicalId,
                                    "type" to "buffering",
                                    "buffering" to true
                                ))
                            }
                            Player.STATE_READY -> {
                                NativeVideoEvents.emit("event", mapOf(
                                    "id" to logicalId,
                                    "type" to "buffering",
                                    "buffering" to false
                                ))
                                NativeVideoEvents.emit("event", mapOf(
                                    "id" to logicalId,
                                    "type" to "ready"
                                ))
                            }
                            Player.STATE_ENDED -> {
                                NativeVideoEvents.emit("event", mapOf(
                                    "id" to logicalId,
                                    "type" to "completed",
                                    "durationMs" to (player?.duration ?: 0L).toInt()
                                ))
                            }
                        }
                    }
                })
            }
        }
        val item = MediaItem.fromUri(url)
        mutedFlag = muted
        unmutedVolume = volume
        player?.apply {
            setMediaItem(item)
            repeatMode = if (loop) Player.REPEAT_MODE_ONE else Player.REPEAT_MODE_OFF
            this.volume = if (mutedFlag) 0f else unmutedVolume
            prepare()
            playWhenReady = autoPlay
        }
        startProgressLoop()
    }

    fun play() { player?.playWhenReady = true; startProgressLoop() }
    fun pause() { player?.playWhenReady = false }
    fun seekTo(ms: Long) { player?.seekTo(ms) }

    fun setVolume(v: Float) {
        unmutedVolume = v
        if (!mutedFlag) player?.volume = v
    }

    fun setMuted(muted: Boolean) {
        mutedFlag = muted
        player?.volume = if (mutedFlag) 0f else unmutedVolume
    }

    private fun startProgressLoop() {
        progressRunnable?.let { handler.removeCallbacks(it) }
        progressRunnable = object : Runnable {
            override fun run() {
                val p = player ?: return
                val pos = p.currentPosition
                val dur = if (p.duration > 0) p.duration else 0L
                NativeVideoEvents.emit("event", mapOf(
                    "id" to logicalId,
                    "type" to "progress",
                    "positionMs" to pos.toInt(),
                    "durationMs" to dur.toInt()
                ))
                handler.postDelayed(this, 250L)
            }
        }
        handler.postDelayed(progressRunnable!!, 250L)
    }

    override fun getView(): View = playerView

    override fun dispose() {
        progressRunnable?.let { handler.removeCallbacks(it) }
        progressRunnable = null
        playerView.player = null
        player?.release()
        player = null
    }
}
