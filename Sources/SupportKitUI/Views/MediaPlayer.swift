import AVKit
import SwiftUI

struct MediaPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    var showsPlaybackControls: Bool = true
    var allowsPictureInPicturePlayback: Bool = true
    var videoGravity: AVLayerVideoGravity = .resizeAspect
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        controller.showsPlaybackControls = showsPlaybackControls
        controller.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        controller.videoGravity = videoGravity
        return controller
    }
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        playerController.player = player
        playerController.showsPlaybackControls = showsPlaybackControls
        playerController.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        playerController.videoGravity = videoGravity
    }
}
