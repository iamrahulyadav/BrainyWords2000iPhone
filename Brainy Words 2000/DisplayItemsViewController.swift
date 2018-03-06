//
//  DisplayItemsViewController.swift
//  Brainy Words 2000
//
//  Created by Numeric on 2/27/18.
//  Copyright © 2018 Brainy Education. All rights reserved.
//

import UIKit

class DisplayItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var fileNameList: [String] = []
    var categoryName: String?
    @IBOutlet weak var horizontalDisplayItemCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        horizontalDisplayItemCollectionView.delegate = self
        horizontalDisplayItemCollectionView.dataSource = self
        horizontalDisplayItemCollectionView.cellsi
    }
    
    func setupData() {
//        guard let
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayItemsCollectionView", for: indexPath)
        return cell
        
    }
    
    
    

    @IBAction func viewQuizQuestions(_ sender: Any) {
    }
    
    @IBAction func popViewControllerTapped(_ sender: Any) {
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class DisplayItemsCollectionView: UICollectionViewCell {
    @IBOutlet weak var wordImageButton: UIButton!
    @IBOutlet weak var nameOfWordLabel: UILabel!
    
    @IBAction func wordImageTapped(_ sender: Any) {
        
    }
    
}
