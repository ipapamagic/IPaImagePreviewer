//
//  ViewController.swift
//  IPaImagePreviewer
//
//  Created by ipapamagic@gmail.com on 08/05/2017.
//  Copyright (c) 2017 ipapamagic@gmail.com. All rights reserved.
//

import UIKit
import IPaImagePreviewer
class ViewController: UIViewController {

    @IBOutlet weak var galleryPreviewView: IPaGalleryPreviewView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        galleryPreviewView.delegate = self
        galleryPreviewView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:IPaGalleryPreviewViewDelegate
{
    func numberOfImages(_ galleryView: IPaGalleryPreviewView) -> Int {
        return 3
    }

    func loadImage(_ galleryView: IPaGalleryPreviewView, index: Int, complete: (UIImage?) -> ()) {
        
        if let path = Bundle.main.path(forResource: "\(index + 1)", ofType: "JPG") {
            complete(UIImage(contentsOfFile: path))
            return
        }
        return complete(nil)
    }
    
}
