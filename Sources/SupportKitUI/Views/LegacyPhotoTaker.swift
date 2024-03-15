import Combine
import AVFoundation
import UIKit
import SwiftUI

@MainActor
public class LegacyPhotoTaker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var continuation: CheckedContinuation<UIImage, Error>? = nil
    
    public enum PhotoError: Error {
        case failed
    }
    
    public override init() { }
    
    public func requestPermission() async -> Bool {
        let result = await AVCaptureDevice.requestAccess(for: .video)
        try? await Task.sleep(for: .seconds(0.5))
        return result
    }
    
    @MainActor
    public func request(cameraDevice: UIImagePickerController.CameraDevice = .front, tint: Color? = nil) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            Task {
                await MainActor.run {
                    let controller = UIImagePickerController()
                    controller.delegate = self
                    controller.sourceType = .camera
                    controller.cameraDevice = cameraDevice
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
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        continuation?.resume(throwing: CancellationError())
    }
}
