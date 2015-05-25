//
//  MarkerDetector.mm
//  AR
//
//  Created by Qijin Zhou on 5/21/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MarkerDetector.h"

@interface MarkerDetector()
{
}
@end


@implementation MarkerDetector: NSObject

-(id) init
{
    self = [super init];

    return self;
}


-(int) processImageBuffer: (CVImageBufferRef) buffer
{
    return (int)CVPixelBufferGetWidth(buffer);
}


@end