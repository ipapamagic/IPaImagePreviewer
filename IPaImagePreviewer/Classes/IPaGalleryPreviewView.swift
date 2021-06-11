//
//  IPaGalleryPreviewView.swift
//  PKCaculatorPro
//
//  Created by IPa Chen on 2015/12/25.
//  Copyright © 2015年 AMagicStudio. All rights reserved.
//

import UIKit
@objc public protocol IPaGalleryPreviewViewDelegate {
    func numberOfImages(_ galleryView:IPaGalleryPreviewView) -> Int
    func loadImage(_ galleryView:IPaGalleryPreviewView,index:Int,complete:@escaping (UIImage?)->()) -> UIImage?
    func customView(_ galleryView:IPaGalleryPreviewView,index:Int,reuseCustomView:UIView?) ->  UIView?
}
open class IPaGalleryPreviewView: UIView {
    lazy var pageViewController:UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.backgroundColor = UIColor.black
        let previewViewController = self.previewViewControllers.first!
        previewViewController.pageIndex = self._currentIndex
        previewViewController.delegate = self
        pageViewController.setViewControllers([previewViewController], direction:.forward, animated: false, completion: nil)
        
        
        return pageViewController
    }()
    lazy var _doubleTapRecognizer:UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(IPaGalleryPreviewView.onZoom(_:)))
        recognizer.numberOfTapsRequired = 2
        recognizer.cancelsTouchesInView = true
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = true
        recognizer.delegate = self
        
        return recognizer
    }()
    var currentPreviewViewController:IPaImagePreviewViewController {
        get {
            for previewViewController in previewViewControllers {
                if previewViewController.pageIndex == _currentIndex {
                    return previewViewController
                }
            }
            return previewViewControllers.first!
        }
    }
    open var doubleTapRecognizer:UITapGestureRecognizer {
        get {
            return _doubleTapRecognizer
        }
    }
    @IBOutlet open var delegate:IPaGalleryPreviewViewDelegate?
    
//    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
//    /// Remove this extra property once Xcode gets fixed.
//    @IBOutlet public var ibDelegate: AnyObject? {
//        get {
//            return delegate
//        }
//        set {
//            delegate = newValue as? IPaGalleryPreviewViewDelegate
//        }
//    }
    lazy var previewViewControllers:[IPaImagePreviewViewController] = {

        let previewViewController = IPaImagePreviewViewController()
        let previewViewController2 = IPaImagePreviewViewController()
        let previewViewController3 = IPaImagePreviewViewController()
        previewViewController.delegate = self
        previewViewController2.delegate = self
        previewViewController3.delegate = self
        return [previewViewController,previewViewController2,previewViewController3]
    }()
    @objc dynamic fileprivate var _currentIndex = 0
    @objc open dynamic var currentIndex:Int {
        get {
            return _currentIndex
        }
        set {
            self._currentIndex = newValue
            self.reloadData()
            self.reloadCurrentPage()
        }
    }
    open var currentImageSize:CGSize {
        get {
            return self.currentPreviewViewController.contentImageView.bounds.size
        }
    }
    @objc class open override func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if key == "currentIndex" {
            return Set<String>(arrayLiteral:"_currentIndex")
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetting()
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetting()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.initialSetting()
    }
    func initialSetting() {
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pageViewController.view)
        let viewsDict:[String:UIView] = ["view": pageViewController.view]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",options:NSLayoutConstraint.FormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",options:NSLayoutConstraint.FormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        self.addGestureRecognizer(self.doubleTapRecognizer)
    }
    open func setCurrentImage(transform:CGAffineTransform)
    {
        self.currentPreviewViewController.contentImageView.transform = transform
    }
    open func reloadCurrentPage() {
        self.currentPreviewViewController.image = self.delegate?.loadImage(self, index: _currentIndex, complete: {
            image in
            self.currentPreviewViewController.image = image
        })
        
        
    }
    open func reloadData() {
        let numberCount = delegate?.numberOfImages(self) ?? 0
        var direction:UIPageViewController.NavigationDirection = .forward
        if _currentIndex >= numberCount {
            _currentIndex = numberCount - 1
            direction = .reverse
        }
        if _currentIndex < 0 {
            _currentIndex = 0
        }
        let thisViewController = currentPreviewViewController
        
        let index = previewViewControllers.firstIndex(of: currentPreviewViewController) ?? 0
        var nextIndex = index + 1
        if nextIndex >= previewViewControllers.count {
            nextIndex = 0
        }
        var lastIndex = index - 1
        if lastIndex < 0 {
            lastIndex = previewViewControllers.count - 1
        }
        let nextViewController = previewViewControllers[nextIndex]
        let lastViewController = previewViewControllers[lastIndex]
        
        
        nextViewController.pageIndex = _currentIndex + 1
        thisViewController.pageIndex = _currentIndex
        lastViewController.pageIndex = _currentIndex - 1
        pageViewController.setViewControllers([thisViewController], direction: direction, animated: false, completion: nil)
    }
    @objc func onZoom(_ sender:UITapGestureRecognizer)
    {
        for previewViewController in previewViewControllers
        {
            if previewViewController.pageIndex == _currentIndex {
                previewViewController.onZoom(sender)
            }
        }
    }
    
}
extension IPaGalleryPreviewView:IPaImagePreviewViewControllerDelegate
{
    func loadImage(index: Int, complete: @escaping (UIImage?,Int) -> ()) -> UIImage? {
        guard index >= 0 , index < (self.delegate?.numberOfImages(self) ?? 0) else {
            return nil
        }
        return self.delegate?.loadImage(self, index: index, complete: {
            image in
            complete(image,index)
        })
    }
    func customView(_ previewViewController:IPaImagePreviewViewController,reuseCustomView:UIView?) ->  UIView?
    {
        return self.delegate?.customView(self, index: previewViewController.pageIndex, reuseCustomView: reuseCustomView)
    }
}
extension IPaGalleryPreviewView:UIPageViewControllerDataSource,UIPageViewControllerDelegate
{
    //MARK : UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let previewViewController = viewController as! IPaImagePreviewViewController
        if previewViewController.pageIndex == 0 {
            return nil
        }
        else if let index = previewViewControllers.firstIndex(of: previewViewController) {
            var lastIndex = index + 2
            while lastIndex >= previewViewControllers.count {
                lastIndex -= previewViewControllers.count
            }
            let beforeViewController = previewViewControllers[ lastIndex]
            
            let index = previewViewController.pageIndex - 1
            beforeViewController.pageIndex = index
            
            return beforeViewController
        
        }
        return nil
    }
    
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let previewViewController = viewController as! IPaImagePreviewViewController
        let numberCount = delegate?.numberOfImages(self) ?? 0
        if previewViewController.pageIndex == (numberCount - 1) {
            return nil
        }
        else if let index = previewViewControllers.firstIndex(of: previewViewController) {
            var nextIndex = index + 1
            while nextIndex >= previewViewControllers.count {
                nextIndex -= previewViewControllers.count
            }
            let nextViewController = previewViewControllers[ nextIndex]
            
            let index = previewViewController.pageIndex + 1
            nextViewController.pageIndex = index
            
            return nextViewController
        }
        return nil
    }
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let viewController = pageViewController.viewControllers!.first! as! IPaImagePreviewViewController
            _currentIndex = viewController.pageIndex
        }
    }
}

extension IPaGalleryPreviewView:UIGestureRecognizerDelegate
{
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}

