import AVFoundation
import Flutter
import UIKit

final class ResizableContainer: UIView {
    var onLayout: ((CGRect) -> Void)?
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?(bounds)
    }
}

class NativeVideoView: NSObject, FlutterPlatformView {
    private let container: ResizableContainer
    private var player: AVPlayer?
    private var layerV: AVPlayerLayer?
    private var timeObserver: Any?
    private var itemObservers: [NSKeyValueObservation] = []
    var logicalId: Int = 0
    private var mutedFlag: Bool = false
    private var unmutedVolume: Float = 1.0

    init(frame: CGRect) {
        container = ResizableContainer(frame: frame)
        container.backgroundColor = .black
        super.init()
        container.onLayout = { [weak self] rect in
            self?.layerV?.frame = rect
        }
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func prepare(url: String, autoPlay: Bool, loop: Bool, volume: Float, muted: Bool) {
        guard let uri = URL(string: url) else { return }
        let item = AVPlayerItem(url: uri)
        let p = AVPlayer(playerItem: item)
        unmutedVolume = volume
        mutedFlag = muted
        p.volume = unmutedVolume
        p.isMuted = mutedFlag
        player = p

        layerV?.removeFromSuperlayer()
        let l = AVPlayerLayer(player: p)
        l.frame = container.bounds
        l.videoGravity = .resizeAspect
        layerV = l
        container.layer.addSublayer(l)

        if loop {
            NotificationCenter.default.addObserver(
                self, selector: #selector(restart),
                name: .AVPlayerItemDidPlayToEndTime, object: item
            )
        }

        addObservers(for: item, player: p)

        if autoPlay { p.play() }

        NativeVideoEventBus.emit("event", [
            "id": logicalId,
            "type": "buffering",
            "buffering": true
        ])
    }

    private func addObservers(for item: AVPlayerItem, player: AVPlayer) {
        timeObserver.map { player.removeTimeObserver($0) }
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 4), queue: .main
        ) { [weak self] t in
            guard let self, let p = self.player, let currentItem = p.currentItem else { return }
            let pos = Int(CMTimeGetSeconds(t) * 1000.0)
            let durSec = CMTimeGetSeconds(currentItem.duration)
            let dur = durSec.isFinite && durSec > 0 ? Int(durSec * 1000.0) : 0
            NativeVideoEventBus.emit("event", [
                "id": self.logicalId,
                "type": "progress",
                "positionMs": pos,
                "durationMs": dur
            ])
        }

        itemObservers.forEach { $0.invalidate() }
        itemObservers.removeAll()

        let obs1 = item.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] item, _ in
            guard let self else { return }
            if item.isPlaybackBufferEmpty {
                NativeVideoEventBus.emit("event", [
                    "id": self.logicalId,
                    "type": "buffering",
                    "buffering": true
                ])
            }
        }

        let obs2 = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
            guard let self else { return }
            NativeVideoEventBus.emit("event", [
                "id": self.logicalId,
                "type": "buffering",
                "buffering": !item.isPlaybackLikelyToKeepUp
            ])
            if item.isPlaybackLikelyToKeepUp {
                NativeVideoEventBus.emit("event", [
                    "id": self.logicalId,
                    "type": "ready"
                ])
            }
        }

        itemObservers.append(contentsOf: [obs1, obs2])

        NotificationCenter.default.addObserver(
            self, selector: #selector(stalled),
            name: .AVPlayerItemPlaybackStalled, object: item
        )
    }

    @objc private func stalled() {
        NativeVideoEventBus.emit("event", [
            "id": logicalId,
            "type": "buffering",
            "buffering": true
        ])
    }

    @objc private func restart() {
        player?.seek(to: .zero)
        player?.play()
    }

    func play() { player?.play() }
    func pause() { player?.pause() }
    func seekTo(milliseconds: Int) { player?.seek(to: CMTime(milliseconds: milliseconds)) }

    func setVolume(_ v: Float) {
        unmutedVolume = v
        if !mutedFlag { player?.volume = v }
    }

    func setMuted(_ m: Bool) {
        mutedFlag = m
        player?.isMuted = m
        if !m { player?.volume = unmutedVolume }
    }

    func view() -> UIView { return container }

    func dispose() {
        NotificationCenter.default.removeObserver(self)
        if let timeObs = timeObserver { player?.removeTimeObserver(timeObs) }
        timeObserver = nil
        itemObservers.forEach { $0.invalidate() }
        itemObservers.removeAll()
        player?.pause()
        player = nil
        layerV?.removeFromSuperlayer()
        layerV = nil
    }
}

private extension CMTime {
    init(milliseconds: Int) { self.init(value: CMTimeValue(milliseconds), timescale: 1000) }
}
