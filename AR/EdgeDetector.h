//
//  EdgeDetector.h
//  AR
//
//  Created by Qijin Zhou on 5/27/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#pragma once

#include <opencv2/opencv.hpp>

class EdgeDetector
{
public:
    void Detect(cv::Mat& frame);
};
