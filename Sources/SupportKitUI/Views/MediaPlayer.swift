import AVKit
import SwiftUI

public struct MediaPlayer: UIViewControllerRepresentable {
    private let player: AVPlayer?
    private var showsPlaybackControls: Bool
    private var allowsPictureInPicturePlayback: Bool
    private var videoGravity: AVLayerVideoGravity
    
    public init(player: AVPlayer?,
         showsPlaybackControls: Bool = true,
         allowsPictureInPicturePlayback: Bool = true,
         videoGravity: AVLayerVideoGravity = .resizeAspect) {
        self.player = player
        self.showsPlaybackControls = showsPlaybackControls
        self.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        self.videoGravity = videoGravity
    }
    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        controller.showsPlaybackControls = showsPlaybackControls
        controller.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        controller.videoGravity = videoGravity
        return controller
    }
    
    public func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        playerController.player = player
        playerController.showsPlaybackControls = showsPlaybackControls
        playerController.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        playerController.videoGravity = videoGravity
    }
}
