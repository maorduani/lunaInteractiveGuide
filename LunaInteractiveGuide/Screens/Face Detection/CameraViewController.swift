//
//  CameraViewController.swift
//  LunaInteractiveGuide
//
//  Created by Maor Duani on 09/07/2023.
//

import UIKit
import AVKit
import Vision

class CameraViewController: UIViewController {

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var faceLayer: CAShapeLayer?
    private var isFaceDetected = false 
    
    private lazy var faceOutOfScreenLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: view.center.x - 100, y: 100, width: 200, height: 100))
        label.text = "Face out of screen"
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .red
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var setupCompletedView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: view.frame.height - 300, width: view.frame.width, height: 300))
        view.backgroundColor = .white
        
        let labelY = 60.0
        let label = UILabel(frame: CGRect(x: view.center.x - 100, y: labelY, width: 200, height: 50))
        label.text = "That it. we got it!"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 22)
        view.addSubview(label)
        
        let button = UIButton(frame: CGRect(x: view.center.x - 50, y: labelY + 50, width: 100, height: 50))
        button.backgroundColor = .blue
        button.layer.cornerRadius = 12
        button.setTitle("Continue", for: .normal)
        button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.addSubview(button)
        
        return view
    }()
   
    var onSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSessionInput()
        configureSessionOutput()
        setupVideoPreviewLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    @objc
    private func continueTapped() {
        endSession()
        onSuccess?()
    }
}

// MARK: - Private Functions
extension CameraViewController {
    
    private func configureSessionInput() {
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .front),
            let input = try? AVCaptureDeviceInput(device: frontCamera),
            captureSession.canAddInput(input) else {
            return
        }
        captureSession.addInput(input)
    }
    
    private func configureSessionOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        let queue = DispatchQueue(label: "com.maorduani.TapAssignment.LunaHomeAssignment")
        videoOutput.setSampleBufferDelegate(self,
                                            queue: queue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
    
    private func setupVideoPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let previewLayer {
            view.layer.insertSublayer(previewLayer, at: 0)
        }
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    private func endSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: faceDetectionCompletionHandler)
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer,
                                                   orientation: .leftMirrored)
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func faceDetectionCompletionHandler(request: VNRequest?, error: Error?) {
        guard error == nil else {
            return
        }
        
        guard let detectionRequest = request as? VNDetectFaceRectanglesRequest,
              let result = detectionRequest.results?.first,
              let faceRectConverted = previewLayer?.layerRectConverted(fromMetadataOutputRect: result.boundingBox) else {
            return
        }
        
        DispatchQueue.main.async {
            self.drawRectangle(around: faceRectConverted)
            if !self.isFaceDetected {
                if self.isInsideScreenBounds(faceRect: faceRectConverted) {
                    self.isFaceDetected = true
                    self.onSuccess?()
                    self.displayStepCompletedView()
                } else {
                    self.displayFaceOuOfBoundsMessge()
                }
            }
        }
    }
    
    private func drawRectangle(around rect: CGRect) {
        let facePath = CGPath(rect: rect, transform: nil)
        faceLayer?.removeFromSuperlayer()
        faceLayer = CAShapeLayer()
        faceLayer?.path = facePath
        faceLayer?.fillColor = UIColor.clear.cgColor
        faceLayer?.strokeColor = UIColor.yellow.cgColor
        view.layer.addSublayer(faceLayer!)
    }
    
    private func displayFaceOuOfBoundsMessge() {
        faceOutOfScreenLabel.removeFromSuperview()
        view.addSubview(faceOutOfScreenLabel)
    }
   
    private func displayStepCompletedView() {
        faceOutOfScreenLabel.removeFromSuperview()
        setupCompletedView.removeFromSuperview()
        setupCompletedView.transform = CGAffineTransform(translationX: 0, y: 300)
        view.addSubview(setupCompletedView)
        
        UIView.animate(withDuration: 0.7, delay: 1) {
            self.setupCompletedView.transform = .identity
        }
    }
    
    private func isInsideScreenBounds(faceRect: CGRect) -> Bool {
        // Added extra padding just to be on the safe side
        // in cases where face rectangle is bit smaller than the actual user's face is
        let verticalPadding: CGFloat = 50
        let horizontalPadding: CGFloat = 20
        let horizontalCheckPassed = faceRect.minX >= horizontalPadding && faceRect.maxX <= view.frame.maxX - horizontalPadding
        let verticalCheckPassed = faceRect.minY >= verticalPadding && faceRect.maxY <= view.frame.maxY - verticalPadding
        return horizontalCheckPassed && verticalCheckPassed
    }
}
