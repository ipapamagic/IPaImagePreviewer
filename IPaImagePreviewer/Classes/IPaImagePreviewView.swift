//
//  IPaImagePreviewView.swift
//  Pods
//
//  Created by IPa Chen on 2017/8/22.
//
//

import UIKit

open class IPaImagePreviewView: UIView {


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    lazy var contentScrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.maximumZoomScale = 4
        scrollView.frame = self.bounds
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        let viewsDict:[String:UIView] = ["view": scrollView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",options:NSLayoutConstraint.FormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",options:NSLayoutConstraint.FormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        
        //   scrollView.addGestureRecognizer(self.doubleTapRecognizer)
        return scrollView
    }()
    
    //    @IBOutlet var singleTapRecognizer: UITapGestureRecognizer!
    lazy var contentImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentScrollView.addSubview(imageView)
        self.imgViewWidthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute:.notAnAttribute, multiplier: 1, constant: self.contentScrollView.bounds.width)
        self.imgViewHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.contentScrollView.bounds.height)
        
        self.imgViewLeadingConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .leading, multiplier: 1, constant: 0)
        
        self.imgViewTopConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .top, multiplier: 1, constant: 0)
        self.imgViewBottomConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.imgViewTrailingConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .trailing, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 0)
        imageView.addConstraints([self.imgViewWidthConstraint,self.imgViewHeightConstraint])
        
        self.contentScrollView.addConstraints([self.imgViewLeadingConstraint,self.imgViewTopConstraint,self.imgViewBottomConstraint,self.imgViewTrailingConstraint])
        
        
        return imageView
    }()
    
    lazy var imgViewHeightConstraint = NSLayoutConstraint()
    lazy var imgViewWidthConstraint = NSLayoutConstraint()
    lazy var imgViewTopConstraint = NSLayoutConstraint()
    lazy var imgViewLeadingConstraint = NSLayoutConstraint()
    lazy var imgViewBottomConstraint = NSLayoutConstraint()
    lazy var imgViewTrailingConstraint = NSLayoutConstraint()
    open var image:UIImage? {
        get {
            return contentImageView.image
        }
        set {
            contentImageView.image = newValue
            contentImageView.transform = .identity
            contentScrollView.setZoomScale(1, animated: false)
          
            self.refreshPicture()
            contentScrollView.layoutIfNeeded()
        }
    }
    open var imageRect:CGRect {
        get {
            return contentImageView.frame
        }
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.refreshPicture()
    }
    open func refreshPicture()
    {
        refreshPictureImageView(contentScrollView.zoomScale)
    }
    func refreshPictureImageView(_ scale:CGFloat)
    {
        
        let viewWidth = self.bounds.width
        let viewHeight = self.bounds.height
        
        var imageWidth:CGFloat = 1
        var imageHeight:CGFloat = 1
        guard let image = image else {
            return
            
        }
        imageWidth = image.size.width
        imageHeight = image.size.height
        let ratio = imageWidth / imageHeight
        let viewRatio = viewWidth / viewHeight
        
        var imageViewWidth:CGFloat
        var imageViewHeight:CGFloat
        if ratio >= viewRatio {
            imageViewWidth = viewWidth * scale
            imageViewHeight = imageViewWidth / ratio
            contentScrollView.contentInset = UIEdgeInsets(top: max(0,max(0,(viewHeight - imageViewHeight) * 0.5)), left: 0, bottom: 0, right: 0)
            //            imgViewLeadingConstraint.constant = 0
            //            imgViewTopConstraint.constant = -max(0,(viewHeight - imageViewHeight) * 0.5)
        }
        else {
            imageViewHeight = viewHeight * scale
            imageViewWidth = imageViewHeight * ratio
            contentScrollView.contentInset = UIEdgeInsets(top: 0, left:max(0,(viewWidth - imageViewWidth) * 0.5), bottom: 0, right: 0)
            //            imgViewTopConstraint.constant = 0
            //            imgViewLeadingConstraint.constant = -max(0,(viewWidth - imageViewWidth) * 0.5)
        }
        imgViewWidthConstraint.constant = (imageViewWidth / scale)
        imgViewHeightConstraint.constant = (imageViewHeight / scale)
        
    }

}
extension IPaImagePreviewView:UIScrollViewDelegate
{
    //MARK:UIScrollViewDelegate
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.refreshPicture()
    }
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentScrollView.layoutIfNeeded()
        })
    }
}
