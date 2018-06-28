//
//  HYPhotoPreviewController.swift
//
//
//  Created by Yan Hu on 2018/5/8.
//  Copyright © 2018年 shinho. All rights reserved.
//

import UIKit
import Kingfisher

public class HYPhotoPreviewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    var label: UILabel!
    var photos: [Any?] = [] {
        didSet {
            if photos.count > index {
                label?.text = "\(index + 1) / \(photos.count)"
            }
        }
    }
    var image: UIImage?
    var index = 0 {
        didSet {
            if photos.count > index {
                collectionView?.selectItem(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                label?.text = "\(index + 1) / \(photos.count)"
            }
        }
    }
    
    var indexChanged: ((_ index: Int) -> ())?
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override public func viewDidLoad() {
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
        collectionView.register(PhotoPreviewCell.self, forCellWithReuseIdentifier: "photo_preview_cell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.frame = CGRect.init(x: 0, y: 44, width: view.frame.size.width, height: 20)
        view.addSubview(label)
        if photos.count > index {
            label.text = "\(index + 1) / \(photos.count)"
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo_preview_cell", for: indexPath) as! PhotoPreviewCell
        cell.photo = photos[indexPath.row]
        cell.dismiss = {
            [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return image == nil ? photos.count : 1
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        index = Int(round(scrollView.contentOffset.x / (view.frame.size.width + 15)))
        image = (collectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as? PhotoPreviewCell)?.preview.image
        indexChanged?(index)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class PhotoPreviewCell: UICollectionViewCell {
    private(set) var preview: HYPhotoPreview!
    var photo: Any? {
        didSet {
            preview.resource = photo
        }
    }
    
    var dismiss: (() -> ())? {
        didSet {
            preview.dismiss = dismiss
        }
    }
    
    var image: UIImage? {
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

class HYPhotoPreview: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var isZoomedIn = false
    private var originalFrame = CGRect.zero
    private var originalCenter = CGPoint.zero
    private var currentMultiple: CGFloat = 1.0
    private var pinchCenter = CGPoint.zero
    private var scrollViewOffset = CGPoint.zero
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var resource: Any? {
        didSet {
            scrollView.setZoomScale(1, animated: true)
            if let image = resource as? UIImage {
                self.image = image
            } else if let urlString = resource as? String {
                if isUrlString(urlString: urlString ) {
                    imageView.kf.setImage(with: URL.init(string: urlString),  completionHandler: {
                        [weak self] (image, error, type, url) in
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
    
    var tapAction: ((_ tap: UITapGestureRecognizer) -> ())?
    var dismiss: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2.0
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        addSubview(scrollView)
        addTap()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        originalFrame = frame
        originalCenter = center
        imageView.frame = bounds
        scrollView.frame = bounds
        scrollView.contentSize = frame.size
        scrollView.bouncesZoom = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        currentMultiple = scale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
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
    
    @objc private func tapAction(tap: UITapGestureRecognizer) {
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
                scrollView.zoom(to: CGRect.init(origin: CGPoint.init(x: point.x  - frame.size.width / 4,
                                                                     y: point.y - frame.size.height / 4),
                                                size: CGSize.init(width: frame.size.width / 2,
                                                                  height: frame.size.height / 2)), animated: true)
            }
        }
        tapAction?(tap)
    }
    
    
    private func isUrlString(urlString: String) -> Bool {
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", "(http|https):\\/\\/([\\w.]+\\/?)\\S*")
        return predicate.evaluate(with: urlString)
    }
    
    private func fileExistsAtPath(path: String?) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path ?? "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


