//
//  FrameFeatureDetector.mm
//  AR
//
//  Created by Qijin Zhou on 5/21/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#import "FrameFeatureDetector.h"

#import <Foundation/Foundation.h>

#import <opencv2/opencv.hpp>

#import "EdgeDetector.h"

@interface FrameFeatureDetector()
{
    EdgeDetector edgeDetector;
}
@end


@implementation FrameFeatureDetector: NSObject

-(CVImageBufferRef) detect: (CVImageBufferRef) buffer
{
    CVPixelBufferLockBaseAddress(buffer, 0);

    uint8_t* baseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(buffer);
    int width = static_cast<int>(CVPixelBufferGetWidth(buffer));
    int height = static_cast<int>(CVPixelBufferGetHeight(buffer));

    cv::Mat frame(height, width, CV_8UC4, (void*)baseAddress);

    edgeDetector.Detect(frame);

    CVPixelBufferUnlockBaseAddress(buffer, 0);

    return nil;
}

@end