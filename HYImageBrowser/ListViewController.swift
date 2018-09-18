//
//  ListViewController.swift
//  HYImageBrowser
//
//  Created by Yan Hu on 2018/6/28.
//  Copyright © 2018年 yan. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        // UIImageView 只有 isRetrieval = true 可以被检索到
        view.isOnlyRetrieval = true
        view.isAutoShowed = true
        
        for i in 0 ..< 4 {
            let image1 = UIImageView.init(frame: CGRect.init(origin: CGPoint.init(x: 10, y: 100 * i + 20), size: CGSize.init(width: 200, height: 100)))
            image1.contentMode = .scaleAspectFit
            image1.clipsToBounds = true
            // 只有标示为 isRetrieval 可以被检索到
            image1.isRetrieval = true
            image1.isUserInteractionEnabled = true
            image1.kf.setImage(with: URL.init(string: "http://img.zcool.cn/community/0117e2571b8b246ac72538120dd8a4.jpg@1280w_1l_2o_100sh.jpg"))
            
            view.addSubview(image1)
        }
        
        let imageGoogle = UIImageView()
        imageGoogle.image = UIImage.init(named: "google")
        imageGoogle.frame = CGRect.init(x: 100, y: 100, width: 100, height: 100)
        view.addSubview(imageGoogle)
        
        let button = UIButton.init(type: .custom)
        view.addSubview(button)
        button.frame = CGRect.init(x: 10, y: 500, width: 50, height: 30)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }
    
    @objc func tapAction() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


class ListViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, HYPhotoPreviewControllerDataSource {
    
    var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView = UITableView.init(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        
        let button = UIButton.init(type: .custom)
        view.addSubview(button)
        button.frame = CGRect.init(x: 10, y: 500, width: 50, height: 30)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }
    
    @objc func tapAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.imageView?.kf.setImage(with: URL.init(string: "http://img.zcool.cn/community/0117e2571b8b246ac72538120dd8a4.jpg@1280w_1l_2o_100sh.jpg"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let vc = HYPhotoTransitionViewController.init(preview: cell?.imageView?.image)
        vc.index = indexPath.row
        vc.previewDataSource = self
        present(vc, animated: true, completion: nil)
    }
    
    func photoPreviewCount() -> Int {
        return 50
    }
    
    func photoPreviewResource(at index: Int) -> Any? {
        return "http://img.zcool.cn/community/0117e2571b8b246ac72538120dd8a4.jpg@1280w_1l_2o_100sh.jpg"
    }
    
    func photoPreviewTransitionFrame(with currentIndex: Int) -> CGRect {
        let cell = tableView.cellForRow(at: IndexPath.init(row: currentIndex, section: 0))
        return cell?.imageView?.rectInWindow ?? .zero
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
