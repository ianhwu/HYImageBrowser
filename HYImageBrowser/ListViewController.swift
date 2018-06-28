//
//  ListViewController.swift
//  HYImageBrowser
//
//  Created by Yan Hu on 2018/6/28.
//  Copyright © 2018年 yan. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView = UITableView.init(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.imageView?.kf.setImage(with: URL.init(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530002174027&di=eb1cbf46ef769f20d8cdbdf1879201fb&imgtype=0&src=http%3A%2F%2Fimg.banbaow.com%2Fuploadfile%2F2015%2F0302%2F15%2F201503021512583260.jpg"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var photos = [Any?]()
        for i in 0 ..< 50 {
            if i == indexPath.row {
                photos.append(tableView.cellForRow(at: indexPath)?.imageView?.image)
            } else {
                photos.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530002174027&di=eb1cbf46ef769f20d8cdbdf1879201fb&imgtype=0&src=http%3A%2F%2Fimg.banbaow.com%2Fuploadfile%2F2015%2F0302%2F15%2F201503021512583260.jpg")
            }
        }
        
        let cells = tableView.visibleCells
        let indexPaths = tableView.indexPathsForVisibleRows
        let frames = cells.map { (cell) -> CGRect in
            return cell.imageView?.rectInWindow ?? .zero
        }
        
        let vc = HYPhotoTransitionViewController.init(fromImage: tableView.cellForRow(at: indexPath)?.imageView?.image, fromFrame: tableView.cellForRow(at: indexPath)?.imageView?.rectInWindow ?? .zero, photos: photos)
        vc.index = indexPath.row
        vc.fromFrames = vc.frames(frames, behind: UInt(indexPaths?.first?.row ?? 0), after: UInt(indexPaths?.last?.row ?? 0))
        present(vc, animated: true, completion: nil)
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

