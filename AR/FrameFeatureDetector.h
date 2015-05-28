//
//  FrameFeatureDetector.h
//  AR
//
//  Created by Qijin Zhou on 5/21/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#pragma once

#import <CoreVideo/CoreVideo.h>

@interface FrameFeatureDetector: NSObject

-(id) init;
-(int) processImageBuffer: (CVImageBufferRef) buffer;
-(CVImageBufferRef) detectEdges: (CVImageBufferRef) buffer;

@end