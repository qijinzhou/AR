//
//  GameViewController.swift
//  AR
//
//  Created by Qijin Zhou on 4/29/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

import AVFoundation
import UIKit
import Metal
import MetalKit

class GameViewController: UIViewController, MTKViewDelegate {

    var device: MTLDevice! = nil

    var textureCache: CVMetalTextureCache! = nil
    var lastCVMetalTexture: CVMetalTexture! = nil

    let inflightSemaphore = DispatchSemaphore(value: 1)

    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil

    let vertexData: [Float] = [
    //     x,    y,    s,    t
        -1.0, -1.0,  1.0,  1.0,
        -1.0,  1.0,  0.0,  1.0,
         1.0,  1.0,  0.0,  0.0,

        -1.0, -1.0,  1.0,  1.0,
         1.0,  1.0,  0.0,  0.0,
         1.0, -1.0,  1.0,  0.0,
    ]
    var vertexBuffer: MTLBuffer! = nil
    var texture: MTLTexture? = nil

    var videoCameraController: VideoCameraController! = nil

    var videoFrameController: MetalVideoFrameController! = nil

    var videoFrameController2: ImageBufferFrameController! = nil

    var frameFeatureDetector: FrameFeatureDetector! = nil

    var grayscaleTextureFilter: GrayscaleTextureFilter! = nil
    var boxBlurTextureFilter: BoxBlurTextureFilter! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        device = MTLCreateSystemDefaultDevice()
        guard device != nil else {
            print("Metal is not supported on this device")
            self.view = UIView(frame: self.view.frame)
            return
        }

        let view = self.view as! MTKView
        view.device = device
        view.delegate = self

        commandQueue = device.makeCommandQueue()
        commandQueue.label = "render command queue"

        let defaultLibrary = device.newDefaultLibrary()!
        let vertexProgram = defaultLibrary.makeFunction(name: "basicVertexShader")!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basicFragmentShader")!

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.sampleCount = view.sampleCount

        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let pipelineError {
            print("Failed to create pipeline state, error \(pipelineError)")
        }

        vertexBuffer = device.makeBuffer(bytes:vertexData, length: vertexData.count * MemoryLayout.size(ofValue: vertexData[0]), options: [])
        vertexBuffer.label = "vertices"

        videoFrameController = MetalVideoFrameController(device: device, delegate:self)

        videoFrameController2 = ImageBufferFrameController(delegate:self)

        videoCameraController = VideoCameraController(delegate: videoFrameController)
        //videoCameraController = VideoCameraController(delegate: videoFrameController2)

        frameFeatureDetector = FrameFeatureDetector()

        var textureCache: CVMetalTextureCache?
        let status = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        if status == kCVReturnSuccess {
            self.textureCache = textureCache!
        } else {
            print("Failed to create CVMetalTextureCache, status \(status)")
        }

        //        let previewLayer = videoCameraController.createPreviewLayer()
        //        previewLayer.frame = view.bounds
        //        view.layer.addSublayer(previewLayer)

        grayscaleTextureFilter = GrayscaleTextureFilter(device: device)
        boxBlurTextureFilter = BoxBlurTextureFilter(device: device)

        videoCameraController.start()
    }

    deinit {
        videoCameraController.stop()
    }

    func update() {
    }

    func draw(in view: MTKView) {
        let _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)

        self.update()

        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.label = "command buffer"

        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
                strongSelf.inflightSemaphore.signal()
            }
        }

        if let texture = texture, let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder.label = "render encoder"
            renderEncoder.pushDebugGroup("draw frame")

            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
            renderEncoder.setFragmentTexture(texture, at: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count, instanceCount: 2)

            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()

            commandBuffer.present(currentDrawable)
        }

        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

}

extension GameViewController: MetalTextureReceiver {
    func onTexture(texture: MTLTexture!) {
        //self.texture = texture
        //self.texture = grayscaleTextureFilter.filter(inTexture: texture)
        let _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)
        self.texture = boxBlurTextureFilter.filter(inTexture: texture)
        inflightSemaphore.signal()
    }
}

extension GameViewController: ImageBufferReceiver {
    func onImageBuffer(buffer: CVImageBuffer!) {
        frameFeatureDetector.detect(buffer)
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)

        var cvMetalTexture: CVMetalTexture?

        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, buffer, nil, MTLPixelFormat.bgra8Unorm, width, height, 0, &cvMetalTexture)

        if let cvMetalTexture = cvMetalTexture,
            let texture = CVMetalTextureGetTexture(cvMetalTexture) {
            let _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)
            self.texture = texture
            self.lastCVMetalTexture = cvMetalTexture
            inflightSemaphore.signal()
        }
    }
}
