//
//  HYPhotoTransitionViewController.swift
//
//  Created by Yan Hu on 2018/5/9.
//  Copyright © 2018年 shinho. All rights reserved.
//

import UIKit

open class HYPhotoTransitionViewController: UIViewController, UIViewControllerTransitioningDelegate {
    /// 图片位置 present 和 dismiss, 不设置默认 alpha 1 -> 0
    open var fromFrames: [CGRect]?
    /// 跳转预览图
    open var imageContentMode: UIView.ContentMode = .scaleAspectFill
    /// 多个数据处理
    open var photos: [Any?] = [] {
        didSet {
            reload()
        }
    }
    
    open var index = 0 {
        didSet {
            child?.index = index
        }
    }
    
    open weak var previewDataSource: HYPhotoPreviewControllerDataSource? {
        didSet {
            child.dataSource = previewDataSource
        }
    }
    
    private var child: HYPhotoPreviewController!
    private var previewImage: UIImage?
    
    public init(preview: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        previewImage = preview
        child = HYPhotoPreviewController()
        addChild(child)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    public func reload() {
        child?.photos = photos.count > 0 ? photos : [previewImage ?? UIImage()]
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissSelf))
        view.addGestureRecognizer(tap)
        
        view.addSubview(child.view)
        child.view.frame = view.bounds
        child.index = index
        child.indexChanged = {
            [unowned self] index in
            self.index = index
            self.previewImage = self.child.image
        }
        reload()
    }
    
    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentation = HYPresentationController.init(presentedViewController: presented, presenting: presenting)
        return presentation
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animatorWithType(type: .dismiss)
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animatorWithType(type: .present)
    }
    
    private func animatorWithType(type: HYPhotoTransitionAnimationType) -> HYPhotoTransitionAnimator {
        let animator = HYPhotoTransitionAnimator()
        animator.duration = 0.3
        animator.animationType = type
        animator.fromImage = previewImage
        if let dataSource = child.dataSource {
            animator.fromFrame = dataSource.photoPreviewTransitionFrame(with: index)
        } else {
            if (fromFrames?.count ?? 0) > index {
                animator.fromFrame = fromFrames![index]
            } else {
                animator.fromFrame = .zero
            }
        }
        animator.imageContentMode = imageContentMode
        return animator
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum HYPhotoTransitionAnimationType {
    case
    present,
    dismiss
}

open class HYPhotoTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    open var duration: TimeInterval = 0.1
    open var animationType = HYPhotoTransitionAnimationType.present
    open var fromImage: UIImage?
    open var fromFrame = CGRect.zero
    open var dismissRect = UIScreen.main.bounds
    open var imageContentMode: UIView.ContentMode!
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    /// 根据图片尺寸, 调整frame, 保证图片居中, width固定, height 动态变化
    public func adjustFrame(rect: CGRect, scaleSize: CGSize) -> CGRect {
        if scaleSize.width == 0 ||
            scaleSize.height == 0 {
            return rect
        }
        let scale = scaleSize.height / scaleSize.width
        let adjustHeight = (rect.width * scale - rect.size.height) / 2.0
        return CGRect.init(x: rect.origin.x, y: rect.origin.y - adjustHeight, width: rect.width, height: rect.width * scale)
    }
    
    /// 判断图片是否在视图中
    public func judgFrameIn(frame: CGRect) -> Bool {
        if frame == .zero {
            return false
        }
        let screenFrame = UIScreen.main.bounds
        return screenFrame.intersects(frame)
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let containerView = transitionContext.containerView
        let imageView = UIImageView()
        let background = UIView()
        background.alpha = 0
        
        var fromFrame = self.fromFrame
        var finalFrame = dismissRect
        finalFrame = adjustFrame(rect: finalFrame, scaleSize: fromImage?.size ?? CGSize.zero)
        
        if animationType == .dismiss {
            fromFrame = finalFrame
            finalFrame = self.fromFrame
            background.alpha = 1
        } else {
            toVC?.view.isHidden = true
        }
        
        imageView.contentMode = imageContentMode
        if judgFrameIn(frame: fromFrame) {
            imageView.frame = fromFrame
        } else {
            imageView.frame = finalFrame
        }
        
        imageView.image = fromImage
        imageView.clipsToBounds = true
        background.frame = UIScreen.main.bounds
        background.backgroundColor = .black
        
        containerView.addSubview(toVC!.view)
        containerView.addSubview(background)
        containerView.addSubview(imageView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            [weak self] in
            background.alpha = self?.animationType == .dismiss ? 0 : 1
            if self?.animationType == .dismiss {
                if self?.judgFrameIn(frame: finalFrame) ?? false {
                    imageView.frame = finalFrame
                } else {
                    imageView.alpha = 0
                }
            } else {
                imageView.frame = finalFrame
            }
        }) { (finished) in
            if finished {
                imageView.removeFromSuperview()
                background.removeFromSuperview()
                toVC?.view.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

fileprivate class HYPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        get {
            return true
        }
    }
}
