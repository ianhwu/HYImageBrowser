//
//  ViewController.swift
//  HYImageBroswer
//
//  Created by Yan Hu on 2018/6/27.
//  Copyright © 2018年 yan. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    var image1: UIImageView!
    var image2: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let content = UIView.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 100), size: CGSize.init(width: 300, height: 600)))
        
        
        image1 = UIImageView.init(frame: CGRect.init(origin: CGPoint.init(x: 10, y: 150), size: CGSize.init(width: 100, height: 200)))
        image1.contentMode = .scaleAspectFit
        image1.clipsToBounds = true
        image1.isUserInteractionEnabled = true
        image1.kf.setImage(with: URL.init(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530002174027&di=eb1cbf46ef769f20d8cdbdf1879201fb&imgtype=0&src=http%3A%2F%2Fimg.banbaow.com%2Fuploadfile%2F2015%2F0302%2F15%2F201503021512583260.jpg"))
        
        image2 = UIImageView.init(frame: CGRect.init(origin: CGPoint.init(x: 10, y: 400), size: CGSize.init(width: 50, height: 70)))
        image2.isUserInteractionEnabled = true
        image2.clipsToBounds = true
        image2.kf.setImage(with: URL.init(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530002174027&di=eb1cbf46ef769f20d8cdbdf1879201fb&imgtype=0&src=http%3A%2F%2Fimg.banbaow.com%2Fuploadfile%2F2015%2F0302%2F15%2F201503021512583260.jpg"))
        image2.contentMode = .scaleAspectFit
        
//        view.addSubview(content)
        view.addSubview(image1)
        view.addSubview(image2)
        
        let tap1 = UITapGestureRecognizer.init(target: self, action: #selector(tap1Action))
        image1.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer.init(target: self, action: #selector(tap2Action))
        image2.addGestureRecognizer(tap2)
    }
    
    @objc func tap1Action() {
        let vc = PhotoTransitionViewController.init(fromImage: image2.image, fromFrame: image2.rectInWindow, photos: ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530002174027&di=eb1cbf46ef769f20d8cdbdf1879201fb&imgtype=0&src=http%3A%2F%2Fimg.banbaow.com%2Fuploadfile%2F2015%2F0302%2F15%2F201503021512583260.jpg", image2.image], imageContentMode: .scaleAspectFit)
        vc.fromFrames = [image1.rectInWindow, image2.rectInWindow]
        present(vc, animated: true) {
            
        }
    }
    
    @objc func tap2Action() {
        let vc = PhotoTransitionViewController.init(fromImage: image2.image, fromFrame: image2.rectInWindow, photos: [image1.image!, "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530002174027&di=eb1cbf46ef769f20d8cdbdf1879201fb&imgtype=0&src=http%3A%2F%2Fimg.banbaow.com%2Fuploadfile%2F2015%2F0302%2F15%2F201503021512583260.jpg"], imageContentMode: .scaleAspectFit)
        vc.index = 1
        vc.fromFrames = [image1.rectInWindow, image2.rectInWindow]
        present(vc, animated: true) {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

