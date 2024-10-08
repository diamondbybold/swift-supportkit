import Foundation
import AVFoundation

//@MainActor
public class AVLoopQueuePlayer: AVQueuePlayer {
    public var loop: Bool = false
    public var playlist: [AVPlayerItem] = []
    
    private nonisolated(unsafe) var task: Task<Void, Never>? = nil
    
    public override init() {
        super.init()
//        task = endTimeTask()
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
        task?.cancel()
    }
    
    private func endTimeTask() -> Task<Void, Never> {
        Task { [weak self] in
            guard let self else { return }
            
            let notification = NotificationCenter.default.notifications(named: .AVPlayerItemDidPlayToEndTime).map({ $0.object as? AVPlayerItem })
            for await playerItem in notification {
                if loop, playlist.last === playerItem {
                    replaceCurrentItems(with: playlist)
                    seek(to: .zero, completionHandler: { _ in })
                    play()
                }
            }
        }
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
