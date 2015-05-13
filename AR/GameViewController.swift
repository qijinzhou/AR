//
//  GameViewController.swift
//  AR
//
//  Created by Qijin Zhou on 4/29/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class GameViewController: UIViewController, MetalTextureReceiver
{
    let device = { MTLCreateSystemDefaultDevice() }()
    let metalLayer = { CAMetalLayer() }()

    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
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

    override func viewDidLoad()
    {
        super.viewDidLoad()

        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true

        self.resize()

        view.layer.addSublayer(metalLayer)
        view.opaque = true
        view.backgroundColor = nil

        commandQueue = device.newCommandQueue()
        commandQueue.label = "command queue"

        let defaultLibrary = device.newDefaultLibrary()
        let vertexProgram = defaultLibrary?.newFunctionWithName("basicVertexShader")
        let fragmentProgram = defaultLibrary?.newFunctionWithName("basicFragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        pipelineDescriptor.sampleCount = 1

        var pipelineError : NSError?
        pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor, error: &pipelineError)
        if (pipelineState == nil)
        {
            println("Failed to create pipeline state, error \(pipelineError)")
        }

        vertexBuffer = device.newBufferWithBytes(vertexData, length: vertexData.count * sizeofValue(vertexData[0]), options: nil)
        vertexBuffer.label = "vertices"

        timer = CADisplayLink(target: self, selector: Selector("renderLoop"))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)

        videoFrameController = MetalVideoFrameController(device: device, delegate:self)

        videoCameraController = VideoCameraController(delegate: videoFrameController)

//        let previewLayer = videoCameraController.createPreviewLayer()
//        previewLayer.frame = view.bounds
//        view.layer.addSublayer(previewLayer)

        videoCameraController.start()
    }

    override func viewDidLayoutSubviews()
    {
        self.resize()
    }

    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }

    deinit
    {
        videoCameraController.stop()

        timer.invalidate()
    }

    func resize()
    {
        if (view.window == nil)
        {
            return
        }

        let window = view.window!
        let nativeScale = window.screen.nativeScale
        view.contentScaleFactor = nativeScale
        metalLayer.frame = view.layer.frame

        var drawableSize = view.bounds.size
        drawableSize.width = drawableSize.width * CGFloat(view.contentScaleFactor)
        drawableSize.height = drawableSize.height * CGFloat(view.contentScaleFactor)
        metalLayer.drawableSize = drawableSize
    }

    func renderLoop()
    {
        autoreleasepool
        {
            self.render()
        }
    }

    func render()
    {
        self.update()

        if (texture == nil)
        {
            return
        }

        let commandBuffer = commandQueue.commandBuffer()
        commandBuffer.label = "command buffer"

        let drawable = metalLayer.nextDrawable()
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .Store

        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)!
        renderEncoder.label = "render encoder"
        renderEncoder.pushDebugGroup("draw frame")

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        renderEncoder.setFragmentTexture(texture, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexData.count, instanceCount: 2)

        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()

        commandBuffer.addCompletedHandler
        {
            [weak self] commandBuffer in
            if let strongSelf = self
            {
            }
            return
        }

        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }

    func update()
    {
    }

    func onTexture(texture: MTLTexture!)
    {
        self.texture = texture
    }
}