//
//  ImageBufferFrameController.swift
//  AR
//
//  Created by Qijin Zhou on 5/21/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

import AVFoundation

protocol ImageBufferReceiver {
    func onImageBuffer(buffer: CVImageBuffer!)
}

class ImageBufferFrameController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var delegate: ImageBufferReceiver!

    init(delegate: ImageBufferReceiver!) {
        super.init()
        self.delegate = delegate
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        self.delegate.onImageBuffer(buffer: buffer)
    }
}
