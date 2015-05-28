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

#import "CVPixelBufferLock.h"
#import "EdgeDetector.h"

@interface FrameFeatureDetector()
{
    EdgeDetector edgeDetector;
}
@end


@implementation FrameFeatureDetector: NSObject

-(CVImageBufferRef) detect: (CVImageBufferRef) buffer
{
    CVPixelBufferLock bufferLock(buffer);

    cv::Mat frame(static_cast<int>(bufferLock.GetHeight()), static_cast<int>(bufferLock.GetWidth()), CV_8UC4, bufferLock.GetAddress());

    edgeDetector.Detect(frame);

    return nil;
}

@end