//
//  IPaGalleryPreviewView.swift
//  PKCaculatorPro
//
//  Created by IPa Chen on 2015/12/25.
//  Copyright © 2015年 AMagicStudio. All rights reserved.
//

import UIKit
public protocol IPaGalleryPreviewViewDelegate {
    func numberOfImagesForGallery(_ galleryView:IPaGalleryPreviewView) -> Int
    func imageForGallery(_ galleryView:IPaGalleryPreviewView,index:Int) -> UIImage?
}
open class IPaGalleryPreviewView: UIView {
    lazy var pageViewController:UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.backgroundColor = UIColor.black
        let previewViewController = self.previewViewControllers.first!
        previewViewController.pageIndex = self.currentIndex
        previewViewController.loadingImage = self.delegate?.imageForGallery(self, index: self.currentIndex)
        pageViewController.setViewControllers([previewViewController], direction:.forward, animated: false, completion: nil)
        
        
        return pageViewController
    }()
    open var delegate:IPaGalleryPreviewViewDelegate!
    lazy var previewViewControllers:[IPaImagePreviewViewController] = {

        let previewViewController = IPaImagePreviewViewController()
        let previewViewController2 = IPaImagePreviewViewController()
        return [previewViewController,previewViewController2]
    }()
    open var currentIndex = 0
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
        self.initialSetting()
    }
    func initialSetting() {
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pageViewController.view)
        let viewsDict:[String:UIView] = ["view": pageViewController.view]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",options:NSLayoutFormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",options:NSLayoutFormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
    }
    
    open func reloadData() {
        let numberCount = delegate!.numberOfImagesForGallery(self)
        var direction:UIPageViewControllerNavigationDirection = .forward
        if currentIndex >= numberCount {
            currentIndex = numberCount - 1
            direction = .reverse
        }
        if currentIndex < 0 {
            currentIndex = 0
        }
        
        let viewController = pageViewController.viewControllers!.first! as! IPaImagePreviewViewController
        var nextViewController:IPaImagePreviewViewController
        let index = previewViewControllers.index(of: viewController)!
        if index == 0 {
            nextViewController = previewViewControllers.last!
        }
        else {
            nextViewController = previewViewControllers.first!
        }
        nextViewController.pageIndex = currentIndex
        nextViewController.loadingImage = delegate?.imageForGallery(self, index: currentIndex)
//        if let loadingImage = nextViewController.loadingImage {
//            nextViewController.image = loadingImage
//        }
        pageViewController.setViewControllers([nextViewController], direction: direction, animated: true, completion: nil)
    }

    
}
extension IPaGalleryPreviewView:UIPageViewControllerDataSource,UIPageViewControllerDelegate
{
    //MARK : UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let previewViewController = viewController as! IPaImagePreviewViewController
        var beforeViewController:IPaImagePreviewViewController?
        if previewViewController.pageIndex == 0 {
            return nil
        }
        else {
            if let index = previewViewControllers.index(of: previewViewController) {
                if index == 0 {
                    beforeViewController = previewViewControllers.last
                }
                else {
                    beforeViewController = previewViewControllers.first
                }
                let index = previewViewController.pageIndex - 1
                beforeViewController!.pageIndex = index
                beforeViewController!.loadingImage = delegate?.imageForGallery(self, index: index)
                
                return beforeViewController
            }
        }
        return nil
    }
    
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let previewViewController = viewController as! IPaImagePreviewViewController
        var afterViewController:IPaImagePreviewViewController?
        let numberCount = delegate!.numberOfImagesForGallery(self)
        if previewViewController.pageIndex == (numberCount - 1) {
            return nil
        }
        else {
            if let index = previewViewControllers.index(of: previewViewController) {
                if index == 0 {
                    afterViewController = previewViewControllers.last
                }
                else {
                    afterViewController = previewViewControllers.first
                }
                let index = previewViewController.pageIndex + 1
                afterViewController!.pageIndex = index
                afterViewController!.loadingImage = delegate?.imageForGallery(self, index: index)
                return afterViewController
            }
        }
        return nil
    }
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let viewController = pageViewController.viewControllers!.first! as! IPaImagePreviewViewController
            currentIndex = viewController.pageIndex
        }
    }
}

