//
//  BoxBlurTextureFilter.swift
//  AR
//
//  Created by Qijin Zhou on 6/4/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

import AVFoundation

class BoxBlurTextureFilter
{
    let device = { MTLCreateSystemDefaultDevice() }()

    var commandQueue: MTLCommandQueue!
    var computePipeline: MTLComputePipelineState!

    init()
    {
        commandQueue = device.newCommandQueue()
        commandQueue.label = "compute command queue"

        let defaultLibrary = device.newDefaultLibrary()!
        let filterShader = defaultLibrary.newFunctionWithName("boxBlur")!

        var error: NSError?
        computePipeline = device.newComputePipelineStateWithFunction(filterShader, error: &error)!
    }

    func filter(inTexture: MTLTexture!) -> MTLTexture!
    {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = MTLPixelFormat.BGRA8Unorm
        textureDescriptor.width = inTexture.width
        textureDescriptor.height = inTexture.height

        let outTexture = device.newTextureWithDescriptor(textureDescriptor)

        let commandBuffer = commandQueue.commandBuffer()

        let computeCommandEncoder = commandBuffer.computeCommandEncoder()

        computeCommandEncoder.setComputePipelineState(computePipeline)
        computeCommandEncoder.setTexture(inTexture, atIndex: 0)
        computeCommandEncoder.setTexture(outTexture, atIndex: 1)

        let threadgroupSize = MTLSize(width: 60, height: 68, depth: 1)
        let threadsPerThreadgroup = MTLSize(width: 32, height: 16, depth: 1)

        computeCommandEncoder.dispatchThreadgroups(threadgroupSize, threadsPerThreadgroup: threadsPerThreadgroup)

        computeCommandEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return outTexture
    }
}