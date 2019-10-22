//
//  UIView+HYImageBrowser.swift
//  HYImageBrowser
//
//  Created by Yan Hu on 2018/9/7.
//  Copyright © 2018年 yan. All rights reserved.
//

import UIKit

private var isOnlyRetrievalKey: Void?
private var isAutoShowedKey: Void?
public extension UIView {
    
    /// 如果 isOnlyRetrieval 为 true, UIImageView isRetrieval 必须为 true才可以显示, 如果为 false, 所有都可以显示
    var isOnlyRetrieval: Bool? {
        set {
            objc_setAssociatedObject(self, &isOnlyRetrievalKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &isOnlyRetrievalKey) as? Bool
        }
    }
    
    /// 在当前 view 上加一个点击, 并且自动检索所有图片 auto set isUserInteractionEnabled = true
    var isAutoShowed: Bool? {
        set {
            var tap: UITapGestureRecognizer!
            if isAutoShowed == nil {
                tap = UITapGestureRecognizer.init(target: self, action: #selector(show(tap:)))
                addGestureRecognizer(tap)
            }
            
            objc_setAssociatedObject(self, &isAutoShowedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            
            tap?.isEnabled = isAutoShowed == true
            if isAutoShowed == true {
                isUserInteractionEnabled = true
            }
        }
        get {
            return objc_getAssociatedObject(self, &isAutoShowedKey) as? Bool
        }
    }
    
    /// 视图在 window 中的位置
    var rectInWindow: CGRect {
        if let window = UIApplication.shared.keyWindow {
            return self.superview?.convert(self.frame, to: window) ?? .zero
        }
        return .zero
    }
    
    @objc private func show(tap: UITapGestureRecognizer) {
        if let window = UIApplication.shared.keyWindow {
            showAllImages(touchPoint: self.convert(tap.location(in: self), to: window))
        }
    }
    
    /// 检索当前页面所有 imageView
    /// 如果未检索到, 不显示
    /// - Parameter touchPoint: 点击位置, 第一个在点击范围的图片为 预览图
    func showAllImages(touchPoint: CGPoint = .zero) {
        var images = [Any]()
        var frames = [CGRect]()
        var currentImage = UIImage()
        var index = 0
        var imageContentMode = UIView.ContentMode.scaleAspectFill
        var foundIndex = false
        
        
        /// 添加图片进入预览数组
        ///
        /// - Parameter imageView: imageView
        func handleImageView(imageView: UIImageView) {
            let rect = imageView.rectInWindow
            if !foundIndex && rect.contains(touchPoint) {
                currentImage = imageView.image ?? UIImage()
                foundIndex = true
                imageContentMode = imageView.contentMode
            } else {
                if !foundIndex {
                    if index == 0 {
                        currentImage = imageView.image ?? UIImage()
                        imageContentMode = imageView.contentMode
                    }
                    index += 1
                }
            }
            
            frames.append(rect)
            if let url = imageView.url {
                images.append(url)
            } else {
                images.append(imageView.image ?? UIImage())
            }
        }
        
        
        /// 判断 UIImageView 是否加入预览
        ///
        /// - Parameters:
        ///   - superView: 父视图
        ///   - sub: 子视图
        func judgePermitted(superView: UIView, sub: UIView) {
            // 父视图只允许有权限的, 则所有子视图都遵循父视图
            if superView.isOnlyRetrieval == true {
                sub.isOnlyRetrieval = true
            }
            
            if let imageView = sub as? UIImageView {
                if superView.isOnlyRetrieval == true {
                    if imageView.isRetrieval == true {
                        handleImageView(imageView: imageView)
                    }
                } else {
                    handleImageView(imageView: imageView)
                }
            }
        }
        
        
        /// 遍历入口
        ///
        /// - Parameter view: 起始视图
        func findImages(view: UIView) {
            for sub in view.subviews {
                if sub.isHidden {
                    continue
                }
                judgePermitted(superView: view, sub: sub)
                findImages(view: sub)
            }
        }
        
        if let superView = self.superview {
            judgePermitted(superView: superView, sub: self)
        }
        findImages(view: self)
        
        if images.count > 0, index < images.count {
            images[index] = currentImage
            let vc = HYPhotoTransitionViewController.init(preview: currentImage)
            vc.photos = images
            vc.imageContentMode = imageContentMode
            vc.fromFrames = frames
            vc.index = index
            topViewController?.present(vc, animated: true, completion: {
                
            })
        }
    }

    var topViewController: UIViewController? {
        if let window = UIApplication.shared.keyWindow {
            return window.currentViewController()
        }
        return nil
    }
}


public extension UIWindow {
    
    /** @return Returns the current Top Most ViewController in hierarchy.   */
    func topMostWindowController()->UIViewController? {
        
        var topController = rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    /** @return Returns the topViewController in stack of topMostWindowController.    */
    func currentViewController()->UIViewController? {
        
        var currentViewController = topMostWindowController()
        
        while currentViewController != nil && currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil {
            currentViewController = (currentViewController as! UINavigationController).topViewController
        }
        
        return currentViewController
    }
}
