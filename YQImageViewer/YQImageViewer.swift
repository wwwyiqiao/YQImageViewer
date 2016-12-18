//
//  YQImageViewer.swift
//  YQImageViewer
//
//  Created by stu on 2016/12/18.
//  Copyright © 2016年 wyq. All rights reserved.
//

import UIKit

class YQImageViewer: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private static let cellIdentifier = "YQImageViewerCellIdentifier"
    
    // views
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.black
        collectionView.register(YQImageViewerCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    //data
    let images: [UIImage]
    
    init(images: [UIImage]) {
        self.images = images
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        self.automaticallyAdjustsScrollViewInsets = false
        
        collectionView.frame = CGRect(x: -10, y: 0, width: self.view.bounds.width + 20, height: self.view.bounds.height)
        pageLabel.frame = CGRect(x: 0, y: 44, width: self.view.bounds.width, height: 21)
        
        didScrollToPage(1)
        
        self.view.addSubview(collectionView)
        self.view.addSubview(pageLabel)
    }
    
    // MARK: - Private
    
    private func didScrollToPage(_ page: Int) {
        pageLabel.text = "\(page)/\(images.count)"
    }

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YQImageViewer.cellIdentifier, for: indexPath) as! YQImageViewerCell
        
        cell.displayImage(images[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    
    // NARK: - UICollectionViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= 0 {
            let page = scrollView.contentOffset.x / collectionView.bounds.width
            didScrollToPage(Int(page) + 1)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.bounds.size.width + 20, height: self.view.bounds.size.height)
    }
    
}





