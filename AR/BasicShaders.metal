//
//  BasicShaders.metal
//  AR
//
//  Created by Qijin Zhou on 4/30/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn
{
    packed_float2 position;
    packed_float2 textureCoord;
};

struct VertexOut
{
    float4 position [[position]];
    float2 textureCoord;
};

vertex VertexOut basicVertexShader(uint vid[[vertex_id]], const device VertexIn* vIn[[buffer(0)]])
{
    VertexOut vOut;
    vOut.position = float4(vIn[vid].position, 0.0, 1.0);
    vOut.textureCoord = vIn[vid].textureCoord;
    return vOut;
}

fragment float4 basicFragmentShader(VertexOut v[[stage_in]], texture2d<float> texture2D[[texture(0)]])
{
    constexpr sampler textureSampler(filter::linear);
    return texture2D.sample(textureSampler, v.textureCoord);
}
