//
//  VideoCameraController.swift
//  AR
//
//  Created by Qijin Zhou on 4/30/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

import AVFoundation

class VideoCameraController
{
    var session: AVCaptureSession!
    var deviceInput: AVCaptureDeviceInput!
    var deviceOutput: AVCaptureVideoDataOutput!

    var queue: dispatch_queue_t!

    init(delegate: AVCaptureVideoDataOutputSampleBufferDelegate!)
    {
        session = AVCaptureSession()
        queue = dispatch_queue_create("VideoCameraController queue", DISPATCH_QUEUE_SERIAL)

        dispatch_async(queue,
        {
            self.setup(delegate)
        })
    }

    func setup(delegate: AVCaptureVideoDataOutputSampleBufferDelegate!)
    {
        self.session.beginConfiguration()

        // Add Input
        var devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var device: AVCaptureDevice!

        for object in devices
        {
            let captureDevice = object as! AVCaptureDevice
            if (captureDevice.position == AVCaptureDevicePosition.Back)
            {
                device = captureDevice
                break
            }
        }

        self.deviceInput = AVCaptureDeviceInput.deviceInputWithDevice(device, error: nil) as! AVCaptureDeviceInput;

        if (self.session.canAddInput(self.deviceInput))
        {
            self.session.addInput(self.deviceInput)
        }

        // Add Output
        var settings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        self.deviceOutput = AVCaptureVideoDataOutput()
        self.deviceOutput.videoSettings = settings
        self.deviceOutput.alwaysDiscardsLateVideoFrames = true

        self.deviceOutput.setSampleBufferDelegate(delegate, queue: self.queue)

        if (self.session.canAddOutput(self.deviceOutput))
        {
            self.session.addOutput(self.deviceOutput)
        }

        self.session.commitConfiguration()
    }

    func start()
    {
        if (self.session.running)
        {
            return
        }

        dispatch_async(self.queue,
        {
            self.session.startRunning()
        })
    }

    func stop()
    {
        if (!self.session.running)
        {
            return
        }

        dispatch_async(self.queue,
        {
            self.session.stopRunning()
        })
    }

    func createPreviewLayer() -> AVCaptureVideoPreviewLayer
    {
        return AVCaptureVideoPreviewLayer.layerWithSession(session) as! AVCaptureVideoPreviewLayer
    }
}