//
//  TextureFilter.swift
//  AR
//
//  Created by Qijin Zhou on 5/29/15.
//  Copyright (c) 2015 Q. All rights reserved.
//

import Foundation

protocol TextureSource
{
    var texture: MTLTexture! { get }
}

protocol TextureSink
{
    var source: TextureSource! { get set }
}

protocol TextureFilter: TextureSource, TextureSink
{
}