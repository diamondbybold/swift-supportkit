import PhotosUI
import UIKit
import SwiftUI

@MainActor
public class LegacyPhotoPicker: PHPickerViewControllerDelegate {
    private var continuation: CheckedContinuation<UIImage, Error>? = nil
    
    public enum PhotoError: Error {
        case failed
    }
    
    public init() { }
    
    public func request(tint: Color? = nil) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            Task {
                await MainActor.run {
                    var config = PHPickerConfiguration()
                    config.filter = .images
                    let controller = PHPickerViewController(configuration: config)
                    controller.modalPresentationStyle = .fullScreen
                    if let tint {
                        controller.view.tintColor = UIColor(tint)
                    }
                    controller.delegate = self
                    UIApplication.shared.topViewController?.present(controller, animated: true)
                }
            }
        }
    }
    
    public func picker(_ picker: PHPickerViewController,
                       didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else {
            continuation?.resume(throwing: CancellationError())
            return
        }
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            continuation?.resume(throwing: PhotoError.failed)
            return
        }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let self else { return }
            
            if let image = image as? UIImage {
                MainActor.assumeIsolated {
                    continuation?.resume(returning: image)
                }
            } else {
                MainActor.assumeIsolated {
                    continuation?.resume(throwing: PhotoError.failed)
                }
            }
        }
    }
}
