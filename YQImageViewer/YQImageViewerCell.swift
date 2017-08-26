//
//  YQImageViewerCell.swift
//  YQImageViewer
//
//  Created by stu on 2016/12/18.
//  Copyright © 2016年 wyq. All rights reserved.
//

import UIKit

class YQImageViewerCell: UICollectionViewCell, UIScrollViewDelegate, YQDetectingTapImageViewDelegate {
    
    // MARK: -  Views
    
    private lazy var zoomingScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 10, y: 0, width: self.bounds.width - 20, height: self.bounds.height))
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        return scrollView
    }()
    
    private lazy var imageView: YQDetectingTapImageView = {
        let imageView = YQDetectingTapImageView(frame: CGRect.zero)
        imageView.delegate = self
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        return imageView
    }()
    
    // MARK: - Properties
    
    weak var activityIndicator: UIActivityIndicatorView?
    var singleTapAction: (() -> Swift.Void)?
    let singleTapGesture = UITapGestureRecognizer()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    deinit {
        self.contentView.removeGestureRecognizer(singleTapGesture)
        self.contentView.removeGestureRecognizer(dragGesture)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.addTarget(self, action: #selector(singleTapGestureAction))
        self.contentView.isUserInteractionEnabled = true
        self.contentView.addGestureRecognizer(singleTapGesture)
        
        
        
        self.contentView.addSubview(zoomingScrollView)
        zoomingScrollView.addSubview(imageView)
    }
    
    // MARK: - Public
    
    func showActivityIndicator() {
        if self.activityIndicator == nil {
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityView.center = self.center
            self.addSubview(activityView)
            self.activityIndicator = activityView
        }
        
        if !self.activityIndicator!.isAnimating {
            self.activityIndicator!.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        if self.activityIndicator != nil {
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.removeFromSuperview()
            self.activityIndicator = nil
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Center the image as it becomes smaller than the size of the screen
        imageView.center = CGPoint(x: imageView.bounds.width / 2, y: imageView.bounds.height / 2)
        
        // Center the image as it becomes smaller than the size of the screen
        let boundsSize = zoomingScrollView.bounds.size
        var frameToCenter = imageView.frame
        
        // Horizontally
        if frameToCenter.size.width < bounds.size.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0)
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0)
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if !imageView.frame.equalTo(frameToCenter) {
            imageView.frame = frameToCenter
        }
    }
    
    func displayImage(_ image: UIImage) {
        zoomingScrollView.maximumZoomScale = 1
        zoomingScrollView.minimumZoomScale = 1;
        zoomingScrollView.zoomScale = 1
        zoomingScrollView.contentSize = CGSize.zero;
        imageView.frame = zoomingScrollView.bounds
        
        self.imageView.image = image
        self.imageView.isHidden = false
        var photoImageViewFrame = CGRect.zero
        photoImageViewFrame.origin = CGPoint.zero
        photoImageViewFrame.size = image.size;
        self.imageView.frame = photoImageViewFrame;
        self.zoomingScrollView.contentSize = photoImageViewFrame.size;
        // Set zoom to minimum zoom
        self.setMaxMinZoomScalesForCurrentBounds()
        self.setNeedsLayout()
    }
    
    // MARK: - Private
    
    private func initialZoomScaleWithMinScale() -> CGFloat {
        var zoomScale = zoomingScrollView.minimumZoomScale
        
        // Zoom image to fill if the aspect ratios are fairly similar
        let boundsSize = zoomingScrollView.bounds.size
        let imageSize = imageView.image!.size
        let boundsAR = boundsSize.width / boundsSize.height
        let imageAR = imageSize.width / imageSize.height
        let xScale = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (abs(boundsAR - imageAR) < 0.17) {
            zoomScale = max(xScale, yScale)
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = min(max(self.zoomingScrollView.minimumZoomScale, zoomScale), self.zoomingScrollView.maximumZoomScale)
        }
        return zoomScale
    }
    
    private func setMaxMinZoomScalesForCurrentBounds() {
        // reset
        zoomingScrollView.maximumZoomScale = 1
        zoomingScrollView.minimumZoomScale = 1
        zoomingScrollView.zoomScale = 1
        guard imageView.image != nil else { return }
        // rest position
        imageView.frame = CGRect(x: 0, y: 0, width: imageView.bounds.width, height: imageView.bounds.height)
        // caculate the Min
        let boundSize = zoomingScrollView.bounds.size
        let imageSize = imageView.image!.size
        let xScale = boundSize.width / imageSize.width      // the scale needed to perfectly fit the image width-wise
        let yScale = boundSize.height / imageSize.height    // the scale needed to perfectly fit the image height-wise
        var minScale = min(xScale, yScale)                  // use minimum of these to allow the image to become fully visible
        // caculate Max
        var maxScale: CGFloat = 1.5
        if UI_USER_INTERFACE_IDIOM() == .pad {
            maxScale = 3
        }
        // Image is smaller than screen so no zooming!
        if (xScale >= 1 && yScale >= 1) {
            minScale = 1.0
        }
        // Set min/max zoom
        zoomingScrollView.maximumZoomScale = maxScale
        zoomingScrollView.minimumZoomScale = minScale
        // Initial zoom
        zoomingScrollView.zoomScale = initialZoomScaleWithMinScale()
        // If we're zooming to fill then centralise
        if (zoomingScrollView.zoomScale != minScale) {
            // Centralise
            zoomingScrollView.contentOffset = CGPoint(x: (imageSize.width * zoomingScrollView.zoomScale - boundSize.width) / 2.0, y: (imageSize.height * self.zoomingScrollView.zoomScale - boundSize.height) / 2.0)
            // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
            self.zoomingScrollView.isScrollEnabled = false
        }
        // Layout
        setNeedsLayout()
    }
    
    // MARK: - User Interaction
    
    @objc private func singleTapGestureAction() {
        singleTapAction?()
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        zoomingScrollView.isScrollEnabled = true
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - YQPreviewImageViewDelegate
    
    func imageViewDoubleTapped(_ imageView: YQDetectingTapImageView, in location: CGPoint) {
        
        if zoomingScrollView.zoomScale != zoomingScrollView.minimumZoomScale
            && zoomingScrollView.zoomScale != initialZoomScaleWithMinScale() {
            zoomingScrollView.setZoomScale(zoomingScrollView.minimumZoomScale, animated: true)
        } else {
            let newZoomScale = (zoomingScrollView.maximumZoomScale + zoomingScrollView.minimumZoomScale) / 2
            let xsize = zoomingScrollView.bounds.width / newZoomScale
            let ysize = zoomingScrollView.bounds.height / newZoomScale
            zoomingScrollView.zoom(to: CGRect(x: location.x - xsize/2, y: location.y - ysize/2, width: xsize, height: ysize), animated: true)
        }
    }
    
    func imageViewSingleTapped(_ imageView: YQDetectingTapImageView, in location: CGPoint) {
        singleTapAction?()
    }
}
