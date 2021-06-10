//
//  IPaImagePreviewViewController.swift
//  PKCaculatorPro
//
//  Created by IPa Chen on 2015/12/25.
//  Copyright © 2015年 AMagicStudio. All rights reserved.
//

import UIKit
import IPaIndicator
protocol IPaImagePreviewViewControllerDelegate
{
    func loadImage(index:Int,complete:@escaping (UIImage?,Int)->()) -> UIImage?
    func customView(_ previewViewController:IPaImagePreviewViewController,reuseCustomView:UIView?) ->  UIView?
}
class IPaImagePreviewViewController: UIViewController,UIScrollViewDelegate,UIGestureRecognizerDelegate{
    var delegate:IPaImagePreviewViewControllerDelegate!
    lazy var previewView:IPaImagePreviewView = {
        let previewView = IPaImagePreviewView(frame:self.view.bounds)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(previewView)
        let viewsDict:[String:UIView] = ["view": previewView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",options:NSLayoutConstraint.FormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",options:NSLayoutConstraint.FormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        
        //   scrollView.addGestureRecognizer(self.doubleTapRecognizer)
        return previewView
    }()
    var contentScrollView:UIScrollView {
        get {
            return previewView.contentScrollView
        }
    }
    var contentImageView:UIImageView {
        get {
            return previewView.contentImageView
        }
    }
    var customView:UIView?
    {
        didSet {
            if let oldValue = oldValue {
                if oldValue == customView {
                    return
                }
                else {
                    oldValue.removeFromSuperview()
                }
            }
            if let customView = customView {
                customView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
                customView.translatesAutoresizingMaskIntoConstraints = true
                
                customView.frame = self.view.bounds
                self.view.addSubview(customView)
                
            }
            
        }
    }
    var image:UIImage? {
        get {
            return previewView.image
        }
        set {
            previewView.image = newValue
        }
    }
    var pageIndex:Int = 0 {
        didSet {
            previewView.image = self.delegate.loadImage(index: pageIndex, complete: {
                loadedImage,index in
                if index == self.pageIndex {
                    self.previewView.image = loadedImage
                }
            })
            
            self.customView = self.delegate.customView(self, reuseCustomView: self.customView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    

    
    func onZoom(_ sender:UITapGestureRecognizer)
    {
        if (contentScrollView.zoomScale > 1) {
            contentScrollView.setZoomScale(1, animated: true)
        }
        else {
            let location = sender.location(in: contentImageView)
            contentScrollView.zoom(to: CGRect(x: location.x - 10, y: location.y - 10, width: 10, height: 10), animated: true)
        }
        
    }
    
        
   
    
    
}
