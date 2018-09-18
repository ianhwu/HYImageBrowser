//
//  HYPhotoPreviewController.swift
//
//
//  Created by Yan Hu on 2018/5/8.
//  Copyright © 2018年 shinho. All rights reserved.
//

import UIKit
import Kingfisher

/// 动态配置方案
public protocol HYPhotoPreviewControllerDataSource: class {
    func photoPreviewCount() -> Int
    func photoPreviewResource(at index: Int) -> Any?
    func photoPreviewTransitionFrame(with currentIndex: Int) -> CGRect
}

open class HYPhotoPreviewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    open var collectionView: UICollectionView!
    open var label: UILabel!
    open var photos: [Any?] = [] {
        didSet {
            if photos.count > index {
                label?.text = "\(index + 1) / \(photos.count)"
            }
        }
    }
    
    /// if set dataSource, photos will be invalid
    weak var dataSource: HYPhotoPreviewControllerDataSource?
    open var image: UIImage?
    open var index = 0 {
        didSet {
            collectionView?.selectItem(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            if let dataSource = dataSource {
                label?.text = "\(index + 1) / \(dataSource.photoPreviewCount())"
            } else {
                label?.text = "\(index + 1) / \(photos.count)"
            }
        }
    }
    
    open var indexChanged: ((_ index: Int) -> ())?
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView.init(frame: CGRect.init(x:0, y: 0, width: view.frame.size.width + 15, height: view.frame.size.height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(HYPhotoPreviewCell.self, forCellWithReuseIdentifier: "photo_preview_cell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.frame = CGRect.init(x: 0, y: 44, width: view.frame.size.width, height: 20)
        view.addSubview(label)
        
        // 初始化显示
        let i = index
        index = i
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo_preview_cell", for: indexPath) as! HYPhotoPreviewCell
        if let dataSource = dataSource {
            cell.photo = dataSource.photoPreviewResource(at: indexPath.row)
        } else {
            cell.photo = photos[indexPath.row]
        }
        cell.dismiss = {
            [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.photoPreviewCount()
        }
        return photos.count
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        index = Int(round(scrollView.contentOffset.x / (view.frame.size.width + 15)))
        image = (collectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as? HYPhotoPreviewCell)?.preview.image
        indexChanged?(index)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class HYPhotoPreviewCell: UICollectionViewCell {
    private(set) var preview: HYPhotoPreview!
    public var photo: Any? {
        didSet {
            preview.resource = photo
        }
    }
    
    public var dismiss: (() -> ())? {
        didSet {
            preview.dismiss = dismiss
        }
    }
    
    public var image: UIImage? {
        didSet {
            preview.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        preview = HYPhotoPreview()
        addSubview(preview)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        preview.frame = CGRect.init(x: 0, y: 0, width: contentView.frame.size.width - 15, height: contentView.frame.size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class HYPhotoPreview: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var loading: UIActivityIndicatorView!
    private var isZoomedIn = false
    private var originalFrame = CGRect.zero
    private var originalCenter = CGPoint.zero
    private var currentMultiple: CGFloat = 1.0
    private var maxMultiple: CGFloat = 2 {
        didSet {
            scrollView?.maximumZoomScale = maxMultiple
        }
    }
    private var pinchCenter = CGPoint.zero
    private var scrollViewOffset = CGPoint.zero
    public var image: UIImage? {
        didSet {
            if let img = image {
                let multiple = img.size.width / img.size.height
                if multiple > 2 {
                    maxMultiple = multiple
                } else {
                    maxMultiple = 2
                }
            }
            imageView.image = image
        }
    }
    
    open var resource: Any? {
        didSet {
            scrollView.setZoomScale(1, animated: true)
            if let image = resource as? UIImage {
                self.image = image
            } else if let urlString = resource as? String {
                if isUrlString(urlString: urlString ) {
                    loading.startAnimating()
                    imageView.kf.setImage(with: URL.init(string: urlString),  completionHandler: {
                        [weak self] (image, error, type, url) in
                        self?.loading.stopAnimating()
                        self?.image = image
                    })
                } else if fileExistsAtPath(path: urlString) {
                    image = UIImage.init(contentsOfFile: urlString)
                } else  {
                    #if DEBUG
                        print(#file , #function, #line, "图片资源不可用", urlString )
                    #endif
                    image = nil
                }
            } else {
                image = nil
            }
        }
    }
    
    open var tapAction: ((_ tap: UITapGestureRecognizer) -> ())?
    open var dismiss: (() -> ())?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        loading = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = maxMultiple
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        addSubview(scrollView)
        imageView.addSubview(loading)
        addTap()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        originalFrame = frame
        originalCenter = center
        imageView.frame = bounds
        scrollView.frame = bounds
        scrollView.contentSize = frame.size
        scrollView.bouncesZoom = true
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        currentMultiple = scale
    }
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private func addTap() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(tap:)))
        addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(tap:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
    }
    
    @objc open func tapAction(tap: UITapGestureRecognizer) {
        scrollViewOffset = CGPoint.zero
        if tap.numberOfTapsRequired == 1 {
            dismiss?()
        } else if tap.numberOfTapsRequired == 2 {
            let point = tap.location(in: self)
            if isZoomedIn && currentMultiple > 1 {
                isZoomedIn = false
                scrollView.setZoomScale(1, animated: true)
            } else {
                isZoomedIn = true
                scrollView.zoom(to: CGRect.init(origin: CGPoint.init(x: point.x  - frame.size.width / (maxMultiple * 2),
                                                                     y: point.y - frame.size.height / (maxMultiple * 2)),
                                                size: CGSize.init(width: frame.size.width / maxMultiple,
                                                                  height: frame.size.height / maxMultiple)), animated: true)
            }
        }
        tapAction?(tap)
    }
    
    
    open func isUrlString(urlString: String) -> Bool {
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", "(http|https):\\/\\/([\\w.]+\\/?)\\S*")
        return predicate.evaluate(with: urlString)
    }
    
    open func fileExistsAtPath(path: String?) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path ?? "")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


