//
//  FilterShaders.metal
//  AR
//
//  Created by Qijin Zhou on 6/2/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant float3 kRec709Luma = float3(0.2126, 0.7152, 0.0722);

kernel void grayscale(texture2d<float, access::read> in[[texture(0)]],
                      texture2d<float, access::write> out[[texture(1)]],
                      uint2 gid[[thread_position_in_grid]])
{
    float4 inColor = in.read(gid);
    float gray = dot(inColor.rgb, kRec709Luma);
    float4 outColor = float4(gray, gray, gray, inColor.a);
    out.write(outColor, gid);
}