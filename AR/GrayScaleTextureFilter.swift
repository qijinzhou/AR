//
//  GrayscaleTextureFilter.swift
//  AR
//
//  Created by Qijin Zhou on 6/2/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

import AVFoundation
import Metal

class GrayscaleTextureFilter {
    var device: MTLDevice!

    var commandQueue: MTLCommandQueue!
    var computePipeline: MTLComputePipelineState!

    init(device: MTLDevice!) {
        self.device = device

        commandQueue = device.makeCommandQueue()
        commandQueue.label = "compute command queue"

        let defaultLibrary = device.newDefaultLibrary()!
        let filterShader = defaultLibrary.makeFunction(name: "grayscale")!

        do {
            computePipeline = try device.makeComputePipelineState(function: filterShader)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }
    }

    func filter(inTexture: MTLTexture!) -> MTLTexture! {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = MTLPixelFormat.bgra8Unorm
        textureDescriptor.width = inTexture.width
        textureDescriptor.height = inTexture.height

        let outTexture = device.makeTexture(descriptor: textureDescriptor)

        let commandBuffer = commandQueue.makeCommandBuffer()

        let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()

        computeCommandEncoder.setComputePipelineState(computePipeline)
        computeCommandEncoder.setTexture(inTexture, at: 0)
        computeCommandEncoder.setTexture(outTexture, at: 1)

        let threadgroupSize = MTLSize(width: 60, height: 68, depth: 1)
        let threadsPerThreadgroup = MTLSize(width: 32, height: 16, depth: 1)

        computeCommandEncoder.dispatchThreadgroups(threadgroupSize, threadsPerThreadgroup: threadsPerThreadgroup)

        computeCommandEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return outTexture
    }
}
