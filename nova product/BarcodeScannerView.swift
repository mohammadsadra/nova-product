//
//  BarcodeScannerView.swift
//  nova product
//
//  Created by Mohammadsadra on 10/1/25.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewRepresentable {
    let onBarcodeScanned: (String) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let captureSession = AVCaptureSession()
        
        // Store the capture session in the view for later use
        view.tag = 999 // Use tag to store reference
        
        // Check camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera(captureSession: captureSession, view: view, context: context)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        setupCamera(captureSession: captureSession, view: view, context: context)
                    } else {
                        print("Camera permission denied")
                    }
                }
            }
        case .denied, .restricted:
            print("Camera access denied or restricted")
        @unknown default:
            print("Unknown camera authorization status")
        }
        
        return view
    }
    
    private func setupCamera(captureSession: AVCaptureSession, view: UIView, context: Context) {
        // Configure session
        captureSession.sessionPreset = .high
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { 
            print("No camera available")
            return 
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error creating video input: \(error)")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Cannot add video input")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr, .code128, .code39, .upce]
        } else {
            print("Cannot add metadata output")
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Store capture session in the view
        objc_setAssociatedObject(view, "captureSession", captureSession, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        DispatchQueue.global(qos: .background).async {
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.layer.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let parent: BarcodeScannerView
        
        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                
                parent.onBarcodeScanned(stringValue)
            }
        }
    }
}
