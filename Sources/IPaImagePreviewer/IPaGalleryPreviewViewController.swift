//
//  IPaGalleryPreviewViewController.swift
//  IPaImagePreviewer
//
//  Created by IPa Chen on 2021/11/18.
//

import UIKit
@objc public protocol IPaGalleryPreviewViewControllerDelegate {
    func numberOfImages(_ galleryViewController:IPaGalleryPreviewViewController) -> Int
    @objc optional func loadImage(_ galleryViewController:IPaGalleryPreviewViewController,index:Int,complete:@escaping (UIImage?)->()) -> UIImage?
    
    @objc optional func imageUrl(for index:Int, galleryViewController:IPaGalleryPreviewViewController) -> URL
    
    @objc optional func configure(_ galleryViewController:IPaGalleryPreviewViewController,index:Int,previewView:UIView)
}
open class IPaGalleryPreviewViewController: UIViewController {
    open weak var delegate:IPaGalleryPreviewViewControllerDelegate?
    public var pageViewCotnroller:UIPageViewController {
        return self.galleryView.pageViewController
    }
    @objc open dynamic var currentIndex:Int {
        get {
            return self.galleryView.currentIndex
        }
        set {
            self.galleryView.currentIndex = newValue
        }
    }
    var galleryView:IPaGalleryPreviewView {
        return self.view as! IPaGalleryPreviewView
    }
    lazy var tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
    public override func loadView() {
        self.view  = IPaGalleryPreviewView(frame: .zero, delegate: self)
        self.view.addGestureRecognizer(self.tapGestureRecognizer)
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.galleryView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @objc func onTap(_ sender:Any) {
        guard let navBar = self.navigationController?.navigationBar else {
            return
        }
        self.navigationController?.setNavigationBarHidden(!navBar.isHidden, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension IPaGalleryPreviewViewController : IPaGalleryPreviewViewDelegate
{
    
    public func numberOfImages(_ galleryView:IPaGalleryPreviewView) -> Int {
        self.delegate?.numberOfImages(self) ?? 0
    }
    public func imageUrl(for index: Int, galleryView: IPaGalleryPreviewView) -> URL? {
        return self.delegate?.imageUrl?(for: index, galleryViewController: self)
    }
    public func loadImage(_ galleryView:IPaGalleryPreviewView,index:Int,complete:@escaping (UIImage?)->()) {
        _ = self.delegate?.loadImage?(self, index: index, complete: complete)
    }
    public func configure(_ galleryView: IPaGalleryPreviewView, index: Int, previewView: UIView) {
        self.delegate?.configure?(self, index: index, previewView: previewView)
        
    }
    
}
