//
//  IPaImagePreviewView.swift
//  Pods
//
//  Created by IPa Chen on 2017/8/22.
//
//

import UIKit
import IPaUIKitHelper
import Combine
open class IPaImagePreviewView: UIView {
    public var zoomScalePublisher = PassthroughSubject<CGFloat, Never>()
    
    public var imageContentEdgeInsets:UIEdgeInsets = .zero {
        didSet {
            refreshPicture()
        }
    }
    //get content image view size from constraints
    public var contentImageViewSize:CGSize {
        get {
            return CGSize(width: imgViewWidthConstraint.constant, height: imgViewHeightConstraint.constant)
        }
    }
    public private(set) lazy var contentScrollView:UIScrollView = {
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
    public private(set) lazy var contentImageContainerView:IPaUIUntouchableView = {
        let view = IPaUIUntouchableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        self.contentScrollView.addSubview(view)
        
        self.imgViewWidthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute:.notAnAttribute, multiplier: 1, constant: self.contentScrollView.bounds.width)
        self.imgViewHeightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.contentScrollView.bounds.height)
        
        self.imgViewLeadingConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        
        self.imgViewTopConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        self.imgViewBottomConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.imgViewTrailingConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        view.addConstraints([self.imgViewWidthConstraint,self.imgViewHeightConstraint])
        
        self.contentScrollView.addConstraints([self.imgViewLeadingConstraint,self.imgViewTopConstraint,self.imgViewBottomConstraint,self.imgViewTrailingConstraint])
        return view
    }()
    //    @IBOutlet var singleTapRecognizer: UITapGestureRecognizer!
    public private(set) lazy var contentImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        self.contentImageContainerView.addSubviewToFill(imageView)
        
        
        return imageView
    }()
    
    lazy var imgViewHeightConstraint = NSLayoutConstraint()
    lazy var imgViewWidthConstraint = NSLayoutConstraint()
    lazy var imgViewTopConstraint = NSLayoutConstraint()
    lazy var imgViewLeadingConstraint = NSLayoutConstraint()
    lazy var imgViewBottomConstraint = NSLayoutConstraint()
    lazy var imgViewTrailingConstraint = NSLayoutConstraint()
    lazy var loadingIndicatorView:UIActivityIndicatorView = {
        var view:UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            view = UIActivityIndicatorView(style: .large)
        } else {
            // Fallback on earlier versions
            view = UIActivityIndicatorView(style: .whiteLarge)
        }
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        view.color = .white
        return view
    }()
    private var contentInsets:UIEdgeInsets {
        get {
            var edgeInsets = self.contentScrollView.contentInset
            edgeInsets.top -= self.imageContentEdgeInsets.top
            edgeInsets.bottom -= self.imageContentEdgeInsets.bottom
            edgeInsets.left -= self.imageContentEdgeInsets.left
            edgeInsets.right -= self.imageContentEdgeInsets.right
            return edgeInsets
        }
        set {
            var edgeInsets = newValue
            edgeInsets.top += self.imageContentEdgeInsets.top
            edgeInsets.bottom += self.imageContentEdgeInsets.bottom
            edgeInsets.left += self.imageContentEdgeInsets.left
            edgeInsets.right += self.imageContentEdgeInsets.right
            contentScrollView.contentInset = edgeInsets
        }
    }
    open var image:UIImage? {
        get {
            return contentImageView.image
        }
        set {
            contentImageView.image = newValue
            
        }
    }
    open var imageUrl:URL? {
        get {
            return contentImageView.imageUrl
        }
        set {
            if newValue != nil ,self.loadingIndicatorView.isHidden{
                self.loadingIndicatorView.isHidden = false
                
                self.bringSubviewToFront(self.loadingIndicatorView)
            }
            contentImageView.imageUrl = newValue
            
            
        }
    }
    open var imageURLString:String? {
        get {
            return contentImageView.imageURLString
        }
        set {
            contentImageView.imageURLString = newValue
        }
    }
    open var imageRect:CGRect {
        get {
            return contentImageView.frame
        }
    }
    fileprivate var imageObserver:NSKeyValueObservation?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetting()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialSetting()
    }
    fileprivate func initialSetting() {
        self.imageObserver = self.contentImageView.observe(\.image) { imageView, Value in
            self.contentImageView.transform = .identity
            self.contentScrollView.setZoomScale(1, animated: false)
          
            self.refreshPicture()
            self.contentScrollView.layoutIfNeeded()
            self.loadingIndicatorView.isHidden = true
        }
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.refreshPicture()
    }
    public func moveToCenter(_ animated:Bool) {
        self.contentScrollView.setContentOffset(CGPoint(x:(self.contentScrollView.contentSize.width  - self.contentScrollView.frame.width) * 0.5,y: (self.contentScrollView.contentSize.height  - self.contentScrollView.frame.height) * 0.5), animated: animated)
    }
    open func refreshPicture()
    {
        refreshPictureImageView(contentScrollView.zoomScale)
    }
    func refreshPictureImageView(_ scale:CGFloat)
    {
        let viewWidth = self.bounds.width - self.imageContentEdgeInsets.right - self.imageContentEdgeInsets.left
        let viewHeight = self.bounds.height - self.imageContentEdgeInsets.top - self.imageContentEdgeInsets.bottom
        
        var imageWidth:CGFloat = 1
        var imageHeight:CGFloat = 1
        guard let image = image else {
            self.contentInsets = .zero
            imgViewWidthConstraint.constant = self.bounds.width
            imgViewHeightConstraint.constant = self.bounds.height
            
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
            self.contentInsets = UIEdgeInsets(top: max(0,max(0,(viewHeight - imageViewHeight) * 0.5)), left: 0, bottom: 0, right: 0)
            
            //            imgViewLeadingConstraint.constant = 0
            //            imgViewTopConstraint.constant = -max(0,(viewHeight - imageViewHeight) * 0.5)
        }
        else {
            imageViewHeight = viewHeight * scale
            imageViewWidth = imageViewHeight * ratio
            self.contentInsets = UIEdgeInsets(top: 0, left:max(0,(viewWidth - imageViewWidth) * 0.5), bottom: 0, right: 0)
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
        return self.contentImageContainerView
    }
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.refreshPicture()
        zoomScalePublisher.send(scrollView.zoomScale)
    }
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentScrollView.layoutIfNeeded()
        })
    }
}
