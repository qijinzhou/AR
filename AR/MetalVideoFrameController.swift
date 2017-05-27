//
//  MetalVideoFrameController.swift
//  AR
//
//  Created by Qijin Zhou on 5/2/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

import AVFoundation

protocol MetalTextureReceiver
{
    func onTexture(texture: MTLTexture!)
}

class MetalVideoFrameController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate
{
    var textureCache: CVMetalTextureCache!
    var lastCVMetalTexture: CVMetalTexture?

    var delegate: MetalTextureReceiver!

    init(device: MTLDevice!, delegate: MetalTextureReceiver!) {
        super.init()

        var textureCache: CVMetalTextureCache?
        let status = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        if status == kCVReturnSuccess {
            self.textureCache = textureCache!
        } else {
            print("Failed to create CVMetalTextureCache, status \(status)")
        }

        self.delegate = delegate
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)

        var cvMetalTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, buffer, nil, MTLPixelFormat.bgra8Unorm, width, height, 0, &cvMetalTexture)
        if let cvMetalTexture = cvMetalTexture,
            let texture = CVMetalTextureGetTexture(cvMetalTexture) {
            delegate.onTexture(texture: texture)
            lastCVMetalTexture = cvMetalTexture
        }
    }
}
