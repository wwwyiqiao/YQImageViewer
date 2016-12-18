//
//  YQDetectingTapImageView.swift
//  YQImageViewer
//
//  Created by stu on 2016/12/18.
//  Copyright © 2016年 wyq. All rights reserved.
//

import UIKit

@objc protocol YQDetectingTapImageViewDelegate: NSObjectProtocol {
    
    @objc optional func imageView(_ imageView: YQDetectingTapImageView, singleTapDetected touch: UITouch)
    
    @objc optional func imageView(_ imageView: YQDetectingTapImageView, doubleTapDetected touch: UITouch)
    
    @objc optional func imageView(_ imageView: YQDetectingTapImageView, tripleTapDetected touch: UITouch)
}

class YQDetectingTapImageView: UIImageView {
    
    weak var delegate: YQDetectingTapImageViewDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
    }
    
    // MARK: Touch Events
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let tapCount = touch.tapCount
        
        switch tapCount {
        case 1:
            delegate?.imageView?(self, singleTapDetected: touch)
        case 2:
            delegate?.imageView?(self, doubleTapDetected: touch)
        case 3:
            delegate?.imageView?(self, tripleTapDetected: touch)
        default:
            break
        }
        
    }
}

