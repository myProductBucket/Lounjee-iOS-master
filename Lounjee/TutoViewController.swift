//
//  TutoViewController.swift
//  Lounjee
//
//  Created by Arnaud AUBRY on 28/04/2016.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class TutoViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    @IBAction func dismissAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func initializeScrollView() {
        var x: CGFloat = 0.0

        for index in 0..<3 {
            let frame = CGRectMake(x, 0.0, self.scrollView.bounds.width, self.scrollView.bounds.height)
            let tutoView = NSBundle.mainBundle().loadNibNamed("TutoView", owner: self, options: nil).first as! TutoView
            let image = UIImage(named: "tuto-\(index + 1)")

            switch (index) {
            case 0:
                tutoView.titleLabel.text = "Tell Lounjee your goals"
                tutoView.detailTextLabel.text = "Login with LinkedIn in seconds and tell us your professional goals."
            case 1:
                tutoView.titleLabel.text = "Discover & Connect"
                tutoView.detailTextLabel.text = "Discover nearby profiles who match your goals and connect with them."
            case 2:
                tutoView.titleLabel.text = "Chat & Meet-up"
                tutoView.detailTextLabel.text = "Set-up an informal meeting and create new business opportunities."
            default:
                print("No more tuto")
            }
            
            tutoView.imageView.image = image
            tutoView.frame = frame
            
            self.scrollView.addSubview(tutoView)
            x += self.scrollView.bounds.width
        }
        
        self.scrollView.contentSize = CGSizeMake(x, self.scrollView.bounds.height)
        self.scrollView.contentOffset = CGPointZero
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        self.initializeScrollView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TutoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        self.pageControl.currentPage = index
    }
}