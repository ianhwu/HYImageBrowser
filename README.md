# HYImageBroswer
load images by kingfisher, support image, url, file path.

## Install
    pod 'HYImageBroswer'
## Usage

find all UIImageView, order by addSubview function.

![](https://github.com/yansaid/HYImageBrowser/blob/master/type1.gif?raw=true)

```
view.isAutoShowed = true  /// use isAutoShowed to show view's subviews which are UIImageView
```
Show images which you want.

![](https://github.com/yansaid/HYImageBrowser/blob/master/type2.gif?raw=true)

```
override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        // UIImageView set isRetrieval true, can be find
        view.isOnlyRetrieval = true
        view.isAutoShowed = true
        
        for i in 0 ..< 4 {
            let image1 = UIImageView.init(frame: CGRect.init(origin: CGPoint.init(x: 10, y: 100 * i + 20), size: CGSize.init(width: 200, height: 100)))
            image1.contentMode = .scaleAspectFit
            image1.clipsToBounds = true
            // it sets isRetrieval true, can be find
            image1.isRetrieval = true
            image1.isUserInteractionEnabled = true
            image1.kf.setImage(with: URL.init(string: "http://img.zcool.cn/community/0117e2571b8b246ac72538120dd8a4.jpg@1280w_1l_2o_100sh.jpg"))
            
            view.addSubview(image1)
        }
        
        let imageGoogle = UIImageView()
        imageGoogle.image = UIImage.init(named: "google")
        imageGoogle.frame = CGRect.init(x: 100, y: 100, width: 100, height: 100)
        view.addSubview(imageGoogle)
    }
```

Handle sources by yourself.

![](https://github.com/yansaid/HYImageBrowser/blob/master/type3.gif?raw=true)

```
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
```

## License

HYImageBroswer is available under the MIT license. See the LICENSE file for more info.
