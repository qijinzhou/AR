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
    var textureCache: CVMetalTextureCacheRef!

    var delegate: MetalTextureReceiver!

    init(device: MTLDevice!, delegate: MetalTextureReceiver!)
    {
        super.init()

        var unamagedCache: Unmanaged<CVMetalTextureCache>?
        CVMetalTextureCacheCreate(nil, nil, device, nil, &unamagedCache)
        textureCache = unamagedCache!.takeRetainedValue()

        self.delegate = delegate
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
    {
        var buffer = CMSampleBufferGetImageBuffer(sampleBuffer)

        var width = CVPixelBufferGetWidth(buffer)
        var height = CVPixelBufferGetHeight(buffer)

        var unmanagedTexture: Unmanaged<CVMetalTexture>?

        var status = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, buffer, nil, MTLPixelFormat.BGRA8Unorm, width, height, 0, &unmanagedTexture)

        if (status != kCVReturnSuccess.value)
        {
            return
        }

        var texture = CVMetalTextureGetTexture(unmanagedTexture!.takeRetainedValue())
        delegate.onTexture(texture)
    }
}