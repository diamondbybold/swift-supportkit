import Combine
import AVFoundation
import UIKit
import SwiftUI

public class LegacyPhotoTaker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var continuation: CheckedContinuation<UIImage, Error>? = nil
    
    public enum PhotoError: Error {
        case failed
    }
    
    public override init() { }
    
    public func requestPermission() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
    
    public func request(tint: Color? = nil) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            Task {
                await MainActor.run {
                    let controller = UIImagePickerController()
                    controller.delegate = self
                    controller.sourceType = .camera
                    controller.cameraDevice = .front
                    controller.cameraViewTransform = CGAffineTransform(scaleX: -1, y: 1)
                    controller.allowsEditing = false
                    if let tint {
                        controller.view.tintColor = UIColor(tint)
                    }
                    UIApplication.shared.topViewController?.present(controller, animated: true)
                }
            }
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            continuation?.resume(throwing: PhotoError.failed)
            return
        }
        
        continuation?.resume(returning: image)
    }
}
