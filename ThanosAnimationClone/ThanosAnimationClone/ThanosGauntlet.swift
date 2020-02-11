//
//  ThanosGauntlet.swift
//  ThanosAnimationClone
//
//  Created by setsu on 2020/02/11.
//  Copyright © 2020 setsu. All rights reserved.
//

import UIKit
import AVFoundation

protocol ThanosGauntletDelegate: class {
    func ThanosGauntletDidSnapped()
    func ThanosGauntletDidReversed()
}

class ThanosGauntlet: UIControl {
    
    weak var delegate: ThanosGauntletDelegate?
    
    private lazy var snapLayer: AnimatableSpriteLayer = {
        return AnimatableSpriteLayer(spriteSheetImage: UIImage.init(named: "thanos_snap")!,
                                     spriteFrameSize: .init(width: 80, height: 80))
    }()
    
    private lazy var snapSoundPlayer = {
        return try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "thanos_snap_sound",
                                                                                    ofType: "mp3")!))
    }()
    
    private lazy var reverseLayer: AnimatableSpriteLayer = {
        return AnimatableSpriteLayer(spriteSheetImage: UIImage.init(named: "thanos_time")!,
                                     spriteFrameSize: .init(width: 80, height: 80))
    }()
    
    private lazy var reverseSoundPlayer = {
        return try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "thanos_reverse_sound",
                                                                                    ofType: "mp3")!))
    }()
    
    enum Action {
        case snap
        case reverse
    }
    
    private var action = Action.snap
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    override func layoutSubviews() {
        snapLayer.position = .init(x: bounds.midX, y: bounds.midY)
        reverseLayer.position = .init(x: bounds.midX, y: bounds.midY)
    }
    
    private func setUpView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.addSublayer(snapLayer)
        
        reverseLayer.isHidden = true
        layer.addSublayer(reverseLayer)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        switch action {
        case .snap:
            
            snapLayer.isHidden = false
            reverseLayer.isHidden = true
            snapLayer.play()
            
            reverseSoundPlayer?.stop()
            reverseSoundPlayer?.currentTime = 0
            snapSoundPlayer?.play()
            
            action = .reverse
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.delegate?.ThanosGauntletDidSnapped()
            }
            
        case .reverse:
            snapLayer.isHidden = true
            reverseLayer.isHidden = false
            reverseLayer.play()
            
            snapSoundPlayer?.stop()
            snapSoundPlayer?.currentTime = 0
            reverseSoundPlayer?.play()
            
            action = .snap
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.delegate?.ThanosGauntletDidReversed()
            }
        }
    }
}
