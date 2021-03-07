//
//  AddListingViewController.swift
//  Bookworm
//
//  Created by Mohammed Haque on 2/28/21.
//

import Foundation
import UIKit
import AVFoundation
import Vision

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AddListingViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scanLabel: UILabel!
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var recognizeTextRequest = VNRecognizeTextRequest()
    var recognizedText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print(error)
            return
        }

        if captureSession?.canAddInput(videoInput) != nil {
            captureSession?.addInput(videoInput)
        } else {
            captureFailed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession?.canAddOutput(metadataOutput) != nil {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        }
        else {
            captureFailed()
            return
        }
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        
        if captureSession?.canAddOutput(videoDataOutput) != nil {
            captureSession?.addOutput(videoDataOutput)
            
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        }
        else {
            captureFailed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
        previewLayer?.frame = imageView.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        imageView.layer.addSublayer(previewLayer ?? AVCaptureVideoPreviewLayer())

        view.bringSubviewToFront(scanLabel)
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.stopAnimating()
        
        captureSession?.startRunning()
        recognizeTextHandler()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        guard let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: outputImage, options: requestOptions)
        
        do {
            try imageRequestHandler.perform([recognizeTextRequest])
        } catch {
            print(error)
            return
        }
    }
    
    func captureFailed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func recognizeTextHandler() {
        recognizeTextRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    self.recognizedText = ""
                    for observation in requestResults {
                        guard let candidiate = observation.topCandidates(1).first else { return }
                        self.recognizedText += candidiate.string
                        self.recognizedText += "\n"
                    }
                    print(self.recognizedText)
                }
            }
        })
        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.usesLanguageCorrection = false
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            self.wait()
            
            OpenLibraryAPI.getAllInfoForISBN(stringValue, bookCoverSize: .M) { (response, error) in
                print(stringValue)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "addListingVC")
                guard let addListingVC = vc as? AddListingViewController else {
                    assertionFailure("couldn't find vc")
                    return
                }
                
                if let bookInfo = response {
                    addListingVC.bookTitle = bookInfo["title"] as? String ?? ""
                    addListingVC.bookPublishDate = bookInfo["publishDate"] as? String ?? ""
                    addListingVC.bookAuthor = bookInfo["author"] as? String ?? ""
                    addListingVC.bookISBN = bookInfo["isbn"] as? String ?? ""
                    addListingVC.bookCoverImageM = bookInfo["imageData"] as? Data
                    addListingVC.delegate = self
                    self.present(addListingVC, animated: true, completion: nil)
                }
                self.start()
            }
        }
    }
    
    // Conversion code taken from stackoverflow
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return cgImage
    }
    
    func addListingVCDismissed() {
        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()        }
    }
    
    //following two functions taken from hw solutions
    func wait() {
        self.activityIndicator.startAnimating()
        self.view.alpha = 0.2
        self.view.isUserInteractionEnabled = false
    }
    func start() {
        self.activityIndicator.stopAnimating()
        self.view.alpha = 1
        self.view.isUserInteractionEnabled = true
    }
}
