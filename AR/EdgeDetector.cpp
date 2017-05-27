//
//  EdgeDetector.cpp
//  AR
//
//  Created by Qijin Zhou on 5/27/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#include "EdgeDetector.h"

void EdgeDetector::Detect(cv::Mat& frame)
{
    cv::Mat grayFrame;
    cv::cvtColor(frame, grayFrame, cv::COLOR_BGRA2GRAY);
    cv::blur(grayFrame, grayFrame, cv::Size(3,3));
    cv::Canny(grayFrame, grayFrame, 20, 60, 3);

    frame = cv::Scalar::all(0);
    frame.setTo(cv::Scalar::all(255), grayFrame);
}
