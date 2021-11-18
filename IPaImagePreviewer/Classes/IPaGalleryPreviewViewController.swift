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
    open var delegate:IPaGalleryPreviewViewControllerDelegate!
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
    public override func loadView() {
        self.view  = IPaGalleryPreviewView(frame: .zero, delegate: self)
        
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.galleryView.reloadData()
        // Do any additional setup after loading the view.
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
        self.delegate.numberOfImages(self)
    }
    public func imageUrl(for index: Int, galleryView: IPaGalleryPreviewView) -> URL? {
        return self.delegate.imageUrl?(for: index, galleryViewController: self)
    }
    public func loadImage(_ galleryView:IPaGalleryPreviewView,index:Int,complete:@escaping (UIImage?)->()) -> UIImage? {
        self.delegate.loadImage?(self, index: index, complete: complete)
    }
    public func configure(_ galleryView: IPaGalleryPreviewView, index: Int, previewView: UIView) {
        self.delegate.configure?(self, index: index, previewView: previewView)
        
    }
    
}
