//
//  VideoCameraController.swift
//  AR
//
//  Created by Qijin Zhou on 4/30/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

import AVFoundation

class VideoCameraController {
    var session: AVCaptureSession!
    var deviceInput: AVCaptureDeviceInput!
    var deviceOutput: AVCaptureVideoDataOutput!

    var queue: DispatchQueue!

    init(delegate: AVCaptureVideoDataOutputSampleBufferDelegate!) {
        session = AVCaptureSession()
        queue = DispatchQueue(label: "VideoCameraController queue")

        queue.async {
            self.setup(delegate: delegate)
        }
    }

    func setup(delegate: AVCaptureVideoDataOutputSampleBufferDelegate!) {
        do {
            self.session.beginConfiguration()

            // Add Input
            let device = defaultCamera()

            self.deviceInput = try AVCaptureDeviceInput(device: device)

            if (self.session.canAddInput(self.deviceInput)) {
                self.session.addInput(self.deviceInput)
            }

            // Add Output
            let settings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

            self.deviceOutput = AVCaptureVideoDataOutput()
            self.deviceOutput.videoSettings = settings
            self.deviceOutput.alwaysDiscardsLateVideoFrames = true

            self.deviceOutput.setSampleBufferDelegate(delegate, queue: self.queue)

            if (self.session.canAddOutput(self.deviceOutput)) {
                self.session.addOutput(self.deviceOutput)
            }

            self.session.commitConfiguration()
        } catch let error {
            print("Failed to setup VideoCaptureController, error \(error)")
        }
    }

    func start() {
        if (self.session.isRunning) {
            return
        }

        queue.async {
            self.session.startRunning()
        }
    }

    func stop() {
        if (!self.session.isRunning) {
            return
        }

        queue.async {
            self.session.stopRunning()
        }
    }

    func createPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return AVCaptureVideoPreviewLayer(session: self.session)
    }

    private func defaultCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDualCamera,
                                                      mediaType: AVMediaTypeVideo,
                                                      position: .back) {
            return device
        }

        if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                                      mediaType: AVMediaTypeVideo,
                                                      position: .back) {
            return device
        }

        return nil
    }
}
