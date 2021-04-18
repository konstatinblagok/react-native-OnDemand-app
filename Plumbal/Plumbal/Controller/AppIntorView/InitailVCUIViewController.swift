
//
//  InitailVCUIViewController.swift
//  Plumbal
//
//  Created by Casperon on 09/10/17.
//  Copyright © 2017 Casperon Tech. All rights reserved.
//

import UIKit

class InitailVCUIViewController: UIViewController {

   //@IBOutlet var imageCollectionVie: UICollectionView!
    @IBOutlet var imageViewWidth: NSLayoutConstraint!
    @IBOutlet var iamgeViewHeight: NSLayoutConstraint!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewWidth.constant = 0.70625*self.view.frame.size.width
         iamgeViewHeight.constant = imageViewWidth.constant
        //        self.imageCollectionVie.delegate = self
//        self.imageCollectionVie.dataSource = self
//        
//        let Nb=UINib(nibName: "InitailVCUIViewController", bundle: nil)
//        
//        imageCollectionVie.registerNib(Nb, forCellWithReuseIdentifier: "cell")
//
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 4
//    }
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//       let cell = imageCollectionVie.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
//        return cell
//    }
//    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
