//
//  BasicShaders.metal
//  AR
//
//  Created by Qijin Zhou on 4/30/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[position]];
    float4 color;
};

vertex Vertex basicVertexShader(uint vid [[ vertex_id ]], constant packed_float4* position [[ buffer(0) ]], constant packed_float4* color [[ buffer(1) ]])
{
    Vertex v;
    v.position = position[vid];
    v.color = color[vid];
    return v;
}

fragment half4 basicFragmentShader(Vertex v [[stage_in]])
{
    return half4(v.color);
}