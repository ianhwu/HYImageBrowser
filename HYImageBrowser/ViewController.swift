//
//  ViewController.swift
//  HYImageBroswer
//
//  Created by Yan Hu on 2018/6/27.
//  Copyright © 2018年 yan. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    var image1: UIImageView!
    var image2: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        image1 = UIImageView.init(frame: CGRect.init(origin: CGPoint.init(x: 10, y: 100), size: CGSize.init(width: 100, height: 200)))
        image1.contentMode = .scaleAspectFit
        image1.clipsToBounds = true
        image1.isUserInteractionEnabled = true
        image1.kf.setImage(with: URL.init(string: "http://img.zcool.cn/community/0117e2571b8b246ac72538120dd8a4.jpg@1280w_1l_2o_100sh.jpg"))
        
        image2 = UIImageView.init(frame: CGRect.init(origin: CGPoint.init(x: 10, y: 300), size: CGSize.init(width: 50, height: 70)))
        image2.contentMode = .scaleAspectFit
        image2.isUserInteractionEnabled = true
        image2.clipsToBounds = true
        image2.kf.setImage(with: URL.init(string: "http://img.zcool.cn/community/0117e2571b8b246ac72538120dd8a4.jpg@1280w_1l_2o_100sh.jpg"))
        
        view.addSubview(image1)
        view.addSubview(image2)
        view.isAutoShowed = true
        
        let button = UIButton.init(type: .custom)
        view.addSubview(button)
        button.frame = CGRect.init(x: 150, y: 400, width: 50, height: 20)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        let button2 = UIButton.init(type: .custom)
        view.addSubview(button2)
        button2.frame = CGRect.init(x: 150, y: 450, width: 50, height: 20)
        button2.backgroundColor = .red
        button2.addTarget(self, action: #selector(tapAction2), for: .touchUpInside)
    }
    
    @objc func tapAction() {
        let vc = ListViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func tapAction2() {
        let vc = ListViewController2()
        self.present(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

