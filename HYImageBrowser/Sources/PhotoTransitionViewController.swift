//
//  PhotoTransitionViewController.swift
//  FSFA
//
//  Created by Yan Hu on 2018/5/9.
//  Copyright © 2018年 shinho. All rights reserved.
//

import UIKit

extension UIView {
    var rectInWindow: CGRect {
        if let window = UIApplication.shared.windows.last {
            return window.convert(self.frame, to: window)
        }
        return CGRect.zero
    }
}

class PhotoTransitionViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var fromImage: UIImage?
    var fromFrames: [CGRect]? // 多张图片
    private(set) var fromFrame: CGRect! {
        didSet {
            fromFrames = [fromFrame]
        }
    }
    var fromImageContentMode: UIViewContentMode = .scaleAspectFill
    var photos: [Any?] = []
    var index = 0
    private var child: PhotoPreviewController!
    
    init(fromImage: UIImage?, fromFrame: CGRect, photos: [Any?], imageContentMode: UIViewContentMode = .scaleAspectFill) {
        super.init(nibName: nil, bundle: nil)
        self.fromImage = fromImage
        self.fromFrame = fromFrame
        self.photos = photos
        self.fromImageContentMode = imageContentMode
        
        child = PhotoPreviewController()
        child.photos = photos
        addChildViewController(child)
        
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(child.view)
        child.view.frame = view.bounds
        child.index = index
        child.indexChanged = {
            [unowned self] index in
            self.index = index
            self.fromImage = self.child.image
        }
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentation = AXPresentationController.init(presentedViewController: presented, presenting: presenting)
        return presentation
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animatorWithType(type: .dismiss)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animatorWithType(type: .present)
    }
    
    private func animatorWithType(type: PhotoTransitionAnimationType) -> PhotoTransitionAnimator {
        let animator = PhotoTransitionAnimator()
        animator.duration = 0.3
        animator.animationType = type
        animator.fromImage = fromImage ?? UIImage()
        if (fromFrames?.count ?? 0) > index {
            animator.fromFrame = fromFrames![index]
        } else {
            animator.fromFrame = fromFrame
        }
        animator.fromImageContentMode = fromImageContentMode
        return animator
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum PhotoTransitionAnimationType {
    case
    present,
    dismiss
}

class PhotoTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: TimeInterval = 0.1
    var animationType = PhotoTransitionAnimationType.present
    var fromImage: UIImage?
    var fromFrame: CGRect = CGRect.zero
    var fromImageContentMode: UIViewContentMode!
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    /// 根据图片尺寸, 调整frame, 保证图片居中, width固定, height 动态变化
    func adjustFrame(rect: CGRect, scaleSize: CGSize) -> CGRect {
        if scaleSize.width == 0 ||
            scaleSize.height == 0 {
            return rect
        }
        let scale = scaleSize.height / scaleSize.width
        let adjustHeight = (rect.width * scale - rect.size.height) / 2.0
        return CGRect.init(x: rect.origin.x, y: rect.origin.y - adjustHeight, width: rect.width, height: rect.width * scale)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let containerView = transitionContext.containerView
        let imageView = UIImageView()
        let background = UIView()
        background.alpha = 0
        
        var fromFrame = self.fromFrame
        var finalFrame = UIScreen.main.bounds
        finalFrame = adjustFrame(rect: finalFrame, scaleSize: fromImage?.size ?? CGSize.zero)
        
        if animationType == .dismiss {
            fromFrame = finalFrame
            finalFrame = self.fromFrame
            background.alpha = 1
        } else {
            toVC?.view.isHidden = true
        }
        
        imageView.contentMode = fromImageContentMode
        imageView.frame = fromFrame
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
                if judgFrameIn(frame: finalFrame) {
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
        
        /// 判断图片是否在视图中
        func judgFrameIn(frame: CGRect) -> Bool {
            var result = true
            let screenFrame = UIScreen.main.bounds
            if frame.origin.x > screenFrame.size.width ||
                frame.origin.y > screenFrame.size.height ||
                frame.origin.x + frame.size.width < 0 ||
                frame.origin.y + frame.size.height < 0
                {
                result = false
            }
            return result
        }
    }
}

class AXPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        get {
            return true
        }
    }
}
