# HYImageBroswer
![](https://github.com/yansaid/HYImageBrowser/blob/master/image_browser.gif)

## Install
    pod 'HYImageBroswer'
## Usage
```
let vc = PhotoTransitionViewController.init(fromImage: image2.image,
    fromFrame: image2.rectInWindow, photos: ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530002174027&di=eb1cbf46ef769f20d8cdbdf1879201fb&imgtype=0&src=http%3A%2F%2Fimg.banbaow.com%2Fuploadfile%2F2015%2F0302%2F15%2F20150                       3021512583260.jpg", image2.image], imageContentMode: .scaleAspectFit)
    vc.fromFrames = [image1.rectInWindow, image2.rectInWindow]
    present(vc, animated: true) {

    }
```

## License

HYTableViewSection is available under the MIT license. See the LICENSE file for more info.
