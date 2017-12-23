//
//  MainStreetViewController.swift
//  Brainy Words 2000
//
//  Created by Numeric on 12/23/17.
//  Copyright © 2017 Brainy Education. All rights reserved.
//

import UIKit

class MainStreetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagesAndButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func testXMLPressed(_ sender: Any) {
        setupImagesAndButtons()
    }
    
    func setupImagesAndButtons() {
        guard let path = Bundle.main.path(forResource: "layout/activity_main", ofType: "xml") else {
            return
        }
        do {
            let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
            let parsedXML = SWXMLHash.parse(data)
            let usefulLayoutInfo = parsedXML["RelativeLayout"]["HorizontalScrollView"]["LinearLayout"].element?.children
            
            for currentBuildingSet in usefulLayoutInfo! {
                if let currentPictureXML = currentBuildingSet as? XMLElement {
                    let imageName = currentPictureXML.attribute(by: "android:background")?.text
                    var normalizedImageName = imageName?.replacingOccurrences(of: "@", with: "assets/")
                    normalizedImageName = "\(normalizedImageName ?? "assets/drawable/back").png"
                    
                    let image = UIImage(named: normalizedImageName!)
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
                    self.view.addSubview(imageView)
                    break

                    for currentButton in currentPictureXML.children {

//                        print("currentPictureXML is \(currentPictureXML), currentButton is \(currentButton)")
                    }
                }
            }

        } catch let error {
            print("Failed to parse XML. \(error)")
        }
    
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
