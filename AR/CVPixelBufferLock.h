//
//  CVPixelBufferLock.h
//  AR
//
//  Created by Qijin Zhou on 5/27/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#pragma once

class CVPixelBufferLock
{
public:
    CVPixelBufferLock(CVImageBufferRef& buffer) : _buffer(buffer)
    {
        CVPixelBufferLockBaseAddress(_buffer, 0);
    }

    ~CVPixelBufferLock()
    {
        CVPixelBufferUnlockBaseAddress(_buffer, 0);
    }

    void* GetAddress()
    {
        return CVPixelBufferGetBaseAddress(_buffer);
    }

    size_t GetWidth()
    {
        return CVPixelBufferGetWidth(_buffer);
    }

    size_t GetHeight()
    {
        return CVPixelBufferGetHeight(_buffer);
    }

private:
    CVImageBufferRef _buffer;
};