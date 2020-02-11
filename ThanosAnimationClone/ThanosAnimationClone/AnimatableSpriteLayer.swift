//
//  AnimatableSpriteLayer.swift
//  ThanosAnimationClone
//
//  Created by setsu on 2020/02/11.
//  Copyright © 2020 setsu. All rights reserved.
//

// Inspired by
// https://www.calayer.com/core-animation/2018/01/05/creating-a-simple-animatable-sprite-layer.html

import UIKit

class AnimatableSpriteLayer: CALayer {
    
    private var animationValues = [CGFloat]()
    
    convenience init(spriteSheetImage: UIImage, spriteFrameSize: CGSize) {
        self.init()
        
        // スプライトの最初のフレームのみを表示するため
        masksToBounds = true
        contentsGravity = .left
        contents = spriteSheetImage.cgImage
        bounds.size = spriteFrameSize
        
        // スプライトのサイズと各画像のサイズに従って画像の数を計算し、各画像のcontentsRect.origin.xオフセットを事前に計算します
        let frameCount = Int(spriteSheetImage.size.width / spriteFrameSize.width)
        for frameIndex in 0..<frameCount {
            animationValues.append(CGFloat(frameIndex) / CGFloat(frameCount))
        }
    }
    
    func play() {
        let spriteKeyframeAnimation = CAKeyframeAnimation(keyPath: "contentsRect.origin.x")
        spriteKeyframeAnimation.values = animationValues
        spriteKeyframeAnimation.duration = 2.0
        spriteKeyframeAnimation.timingFunction = .init(name: .linear)
        // valuesで指定されたキーフレーム値を使用してキーフレームアニメーションが順次変更されるようにするため
        spriteKeyframeAnimation.calculationMode = .discrete
        add(spriteKeyframeAnimation, forKey: nil)
    }
}
