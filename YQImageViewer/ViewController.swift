//
//  ViewController.swift
//  YQImageViewer
//
//  Created by stu on 2016/12/18.
//  Copyright © 2016年 wyq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tappedOnButton() {
        let images = [UIImage(named: "phone_bg1")!, UIImage(named: "phone_bg2")!, UIImage(named: "phone_bg3")!]
        let imageViewer = YQImageViewer(images: images)
        let navi = UINavigationController(rootViewController: imageViewer)
        self.present(navi, animated: true, completion: nil)
    }

}

