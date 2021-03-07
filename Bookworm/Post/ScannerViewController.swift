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
import VisionKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, VNDocumentCameraViewControllerDelegate, AddListingViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scanLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var recognizeTextRequest = VNRecognizeTextRequest()
    var recognizedText = ""
    var captureTimer = Timer()
    var timePassed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerCalled), userInfo: nil, repeats: true)
        
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

    @IBAction func scanButtonPressed() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        self.present(documentCameraViewController, animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let image = scan.imageOfPage(at: 0)
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do {
            try handler.perform([recognizeTextRequest])
        } catch {
            print(error)
        }
        controller.dismiss(animated: true)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//        var requestOptions:[VNImageOption : Any] = [:]
//
//        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
//            requestOptions = [.cameraIntrinsics:camData]
//        }
//
//        if timePassed {
//            guard let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
//            let imageRequestHandler = VNImageRequestHandler(cgImage: outputImage, options: requestOptions)
//
//            do {
//                try imageRequestHandler.perform([recognizeTextRequest])
//            } catch {
//                print(error)
//                return
//            }
//            timePassed = false
//        }
        if timePassed {
            let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .down)

            let request = VNRecognizeTextRequest(completionHandler: textDetectHandler)

            do {
                // Perform the text-detection request.
                try requestHandler.perform([request])
            } catch {
                print("Unable to perform the request: \(error).")
            }
            timePassed = false
        }
    }
    
    func textDetectHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else { return }
        // Process each observation to find the recognized body pose points.
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        print(recognizedStrings)
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
            captureTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerCalled), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if captureSession?.isRunning == false {
            captureSession?.startRunning()
            captureTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerCalled), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
            captureTimer.invalidate()
        }
    }
    
    @objc func timerCalled() {
        timePassed = true
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
