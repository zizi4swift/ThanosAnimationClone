//
//  DustEffectView.swift
//  ThanosAnimationClone
//
//  Created by setsu on 2020/02/11.
//  Copyright © 2020 setsu. All rights reserved.
//

import UIKit
import AVFoundation

protocol DustEffectViewDelegate: class {
    func DustEffectDidCompleted()
}

class DustEffectView: UIView, CAAnimationDelegate {
    
    // MARK: - Variables
    weak var delegate: DustEffectViewDelegate?
    var soundPlayer: AVAudioPlayer?
    
    var image: UIImage? {
        didSet {
            
            if let image = image {
                let images = createDustImages(image: image)
                let imagesCount = images.count
                
                for (i, image) in images.enumerated() {
                    let layer = CALayer()
                    layer.frame = bounds
                    layer.contents = image.cgImage
                    self.layer.addSublayer(layer)
                    
                    let centerX = Double(layer.position.x)
                    let centerY = Double(layer.position.y)
                    
                    // attach animation
                    let radian1 = Double.pi / 12 * Double.random(in: -0.5..<0.5)
                    let radian2 = Double.pi / 12 * Double.random(in: -0.5..<0.5)
                    
                    let random = Double.pi * 2 * Double.random(in: -0.5..<0.5)
                    let transX = 30 * cos(random)
                    let transY = 15 * sin(random)
                    
                    let realTransX = transX * cos(radian1) - transY * sin(radian1)
                    let realTransY = transY * cos(radian1) - transX * sin(radian1)
                    let realEndPoint = CGPoint(x: centerX + realTransX, y: centerY + realTransY)
                    let controlPoint = CGPoint(x: centerX + transX, y: centerY + transY)
                    
                    let movePath = UIBezierPath()
                    movePath.move(to: layer.position)
                    movePath.addQuadCurve(to: realEndPoint, controlPoint: controlPoint)
                    
                    let moveAnimation = CAKeyframeAnimation(keyPath: "position")
                    moveAnimation.path = movePath.cgPath
                    moveAnimation.calculationMode = .paced
                    
                    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
                    rotateAnimation.toValue = radian1 + radian2
                    
                    let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
                    
                    fadeOutAnimation.toValue = 0.0
                    
                    let animationGroup = CAAnimationGroup()
                    animationGroup.animations = [moveAnimation, rotateAnimation, fadeOutAnimation]
                    animationGroup.duration = 1
                    animationGroup.beginTime = CACurrentMediaTime() + 1.35 * Double(i) / Double(imagesCount)
                    animationGroup.isRemovedOnCompletion = false
                    animationGroup.fillMode = .forwards
                    
                    if i == images.count - 1 {
                        animationGroup.delegate = self
                    }
                    
                    layer.add(animationGroup, forKey: nil)
                }
                
                soundPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "thanos_dust_\(Int.random(in: 1...6))", ofType: "mp3")!))
                if soundPlayer != nil {
                    soundPlayer!.prepareToPlay()
                    soundPlayer!.play()
                }
            }
        }
    }
    
    // MARK: - Initialize Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createDustImages(image: UIImage) -> [UIImage] {
        var result = [UIImage]()
        guard let inputCGImage = image.cgImage else { return result }
        
        // 指定された形式に従ってビットマップコンテキストを作成し、描画後に入力画像のピクセルデータを描画します
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else { return result }
        context.draw(inputCGImage, in: .init(x: 0,
                                             y: 0,
                                             width: width,
                                             height: height))
        guard let buffer = context.data else { return result }
        let pixelBuffer = buffer.bindMemory(to: UInt32.self,
                                            capacity: width * height)
        // ピクセルの2次元配列を作成し、入力画像の各ピクセルをトラバースし、配列の32個の要素の1つと同じ位置にランダムに割り当てます
        let imagesCount = 32
        var framePixels = Array(repeating: Array(repeating: UInt32(0),
                                                 count: width * height),
                                count: imagesCount)
        
        for column in 0..<width {
            for row in 0..<height {
                let offset = row * width + column
                for _ in 0...1 {
                    let temp = Double.random(in: 0..<1) + 2 * (Double(column)/Double(width))
                    let index = Int(floor(Double(imagesCount) * ( temp / 3)))
                    framePixels[index][offset] = pixelBuffer[offset]
                }
            }
        }
        
        for frame in framePixels {
            let data = UnsafeMutablePointer(mutating: frame)
            guard let context = CGContext(data: data,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: bitsPerComponent,
                                          bytesPerRow: bytesPerRow,
                                          space: colorSpace,
                                          bitmapInfo: bitmapInfo) else { continue }
            
            guard let cgImage = context.makeImage() else { return result }
            result.append(UIImage(cgImage: cgImage,
                                  scale: image.scale,
                                  orientation: image.imageOrientation))
        }
        
        return result
    }
}
