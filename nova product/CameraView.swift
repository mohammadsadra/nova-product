//
//  CameraView.swift
//  nova product
//
//  Created by Mohammadsadra on 10/1/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct PhotoCaptureView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoCaptureView
        
        init(_ parent: PhotoCaptureView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.onImageCaptured(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.onImageCaptured(originalImage)
            } else {
                parent.onImageCaptured(nil)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageCaptured(nil)
        }
    }
}
