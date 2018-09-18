//
//  UIImageView+HYImageBrowser.swift
//  HYImageBrowser
//
//  Created by Yan Hu on 2018/9/7.
//  Copyright © 2018年 yan. All rights reserved.
//

import UIKit

private var hyImageViewUrlKey: Void?
private var hyIsRetrievalKey: Void?
private var hideNotPermittedKey: Void?
private var showPreviewPermittedKey: Void?

public extension UIImageView {
    /// 检索图片, 如果 UIImageView 有 url, 则使用 url, 否则使用 UIImageView 的 image
    public var url: String? {
        set {
            objc_setAssociatedObject(self, &hyImageViewUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &hyImageViewUrlKey) as? String
        }
    }
    
    /// 配合图片检索, 如果 父视图 的 hideNotPermitted 为 true, 只有 isRetrieval 的子 UIImageView 可以显示
    public var isRetrieval: Bool? {
        set {
            objc_setAssociatedObject(self, &hyIsRetrievalKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &hyIsRetrievalKey) as? Bool
        }
    }
    
    
    /// 预览自己
    ///
    /// - Parameter completion: 动画结束回调
    public func showPreview(completion: (() -> ())? = nil) {
        let vc = HYPhotoTransitionViewController.init(preview: image)
        vc.photos = [image]
        vc.fromFrames = [rectInWindow]
        topViewController?.present(vc, animated: true, completion: completion)
    }
}
