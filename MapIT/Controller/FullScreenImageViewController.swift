//
//  FullScreenImageViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/30.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var backgroundview: UIView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    var photos = [String]()
    var imageFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var selectedIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UIPanGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        backgroundview.addGestureRecognizer(tap)
        setScrollView()
        scrollView.clipsToBounds = true

    }
    func setScrollView() {
        pageController.numberOfPages = photos.count
        pageController.currentPage = 0
        pageController.currentPageIndicatorTintColor = UIColor.MiraBlue
        pageController.pageIndicatorTintColor = .lightGray
        for index in 0...photos.count - 1 {
            let photo = photos[index]
            print(photo)
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
            let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            if let dirPath = paths.first {
                let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(photo)
                let image    = UIImage(contentsOfFile: imageURL.path)
                imageFrame.origin.x = scrollView.frame.size.width * CGFloat(index)
                imageFrame.size = scrollView.frame.size
                let imageView = UIImageView(frame: imageFrame)
                imageView.image = image
                self.scrollView.addSubview(imageView)
            }
        }
        scrollView.contentSize.width = (scrollView.frame.width) * CGFloat(photos.count)
        scrollView.contentSize.height = scrollView.frame.height
        scrollView.delegate = self

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
    }
    @objc func dismissFullscreenImage(_ sender: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.8, animations: {
//            sender.view?.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        })
    }
    @IBAction func back(_ sender: UIButton) {
         self.dismiss(animated: true, completion: nil)
    }
    @IBAction func pageChanged(_ sender: UIPageControl) {
        let currentPageNumber = sender.currentPage
        let width = scrollView.frame.size.width
        let offset = CGPoint(x: width * CGFloat(currentPageNumber), y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageController.currentPage = currentPage
    }
}
