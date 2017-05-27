//
//  FrameFeatureDetector.h
//  AR
//
//  Created by Qijin Zhou on 5/21/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#import <CoreVideo/CoreVideo.h>

@interface FrameFeatureDetector: NSObject

-(CVImageBufferRef) detect: (CVImageBufferRef) buffer;

@end
