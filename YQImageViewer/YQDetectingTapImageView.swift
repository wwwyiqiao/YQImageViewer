//
//  YQDetectingTapImageView.swift
//  YQImageViewer
//
//  Created by stu on 2016/12/18.
//  Copyright © 2016年 wyq. All rights reserved.
//

import UIKit

@objc protocol YQDetectingTapImageViewDelegate: NSObjectProtocol {
    
    @objc optional func imageViewSingleTapped(_ imageView: YQDetectingTapImageView, in location: CGPoint)
    
    @objc optional func imageViewDoubleTapped(_ imageView: YQDetectingTapImageView, in location: CGPoint)
}

class YQDetectingTapImageView: UIImageView, UIGestureRecognizerDelegate {
    
    weak var delegate: YQDetectingTapImageViewDelegate?
    
    private let oneTapGesture = UITapGestureRecognizer()
    private let doubleTapGesture = UITapGestureRecognizer()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        self.removeGestureRecognizer(oneTapGesture)
        self.removeGestureRecognizer(doubleTapGesture)
    }
    
    // MARK: Setup
    
    private func setup() {
        self.isUserInteractionEnabled = true
        
        oneTapGesture.numberOfTapsRequired = 1
        oneTapGesture.delegate = self
        oneTapGesture.addTarget(self, action: #selector(tappedAction))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        doubleTapGesture.addTarget(self, action: #selector(tappedAction))
        
        self.addGestureRecognizer(oneTapGesture)
        self.addGestureRecognizer(doubleTapGesture)
    }
    
    
    // MARK: - User Interaction
    
    func tappedAction(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        
        switch recognizer {
        case oneTapGesture:
            delegate?.imageViewSingleTapped?(self, in: location)
        case doubleTapGesture:
            delegate?.imageViewDoubleTapped?(self, in: location)
        default:
            break
        }
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if( gestureRecognizer == oneTapGesture && otherGestureRecognizer == doubleTapGesture) {
            return true
        }
        return false
    }
}


