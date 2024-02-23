import Foundation
import AVFoundation

public class AVLoopQueuePlayer: AVQueuePlayer {
    public var loop: Bool = false
    public var playlist: [AVPlayerItem] = []
    
    private var songDidEndTask: Task<Void, Never>? = nil
    
    public override init() {
        super.init()
        
        songDidEndTask = Task { [weak self] in
            let notifications = NotificationCenter.default.notifications(named: .AVPlayerItemDidPlayToEndTime)
            for await notification in notifications {
                guard let self else { return }
                if loop, playlist.last === notification.object as? AVPlayerItem {
                    replaceCurrentItems(with: playlist)
                    seek(to: .zero, completionHandler: { _ in })
                    play()
                }
            }
        }
    }
    
    public override init(url URL: URL) {
        super.init(url: URL)
        playlist = [AVPlayerItem(url: URL)]
    }
    
    public override init(items: [AVPlayerItem]) {
        super.init(items: items)
        playlist = items
    }
    
    public override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        if let item { playlist = [item] }
    }
    
    deinit {
        songDidEndTask?.cancel()
    }
    
    public func replaceCurrentItems(with items: [AVPlayerItem]) {
        removeAllItems()
        playlist = items
        playlist.forEach { insert($0, after: nil) }
    }
    
    public func replaceCurrentURLs(with urls: [URL]) {
        let items = urls.map { AVPlayerItem(url: $0) }
        replaceCurrentItems(with: items)
    }
}
