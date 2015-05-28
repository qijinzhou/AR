//
//  FrameFeatureDetector.mm
//  AR
//
//  Created by Qijin Zhou on 5/21/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FrameFeatureDetector.h"

#import <opencv2/opencv.hpp>

@interface FrameFeatureDetector()
{
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

    cv::Mat grayFrame;
    cv::cvtColor(frame, grayFrame, cv::COLOR_BGRA2GRAY);
    cv::blur(grayFrame, grayFrame, cv::Size(3,3));
    cv::Canny(grayFrame, grayFrame, 20, 60, 3);

    frame = cv::Scalar::all(0);
    frame.setTo(cv::Scalar::all(255), grayFrame);

    CVPixelBufferUnlockBaseAddress(buffer, 0);

    return nil;
}

@end