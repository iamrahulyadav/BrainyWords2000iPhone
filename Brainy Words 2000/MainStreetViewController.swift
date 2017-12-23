//
//  MainStreetViewController.swift
//  Brainy Words 2000
//
//  Created by Numeric on 12/23/17.
//  Copyright © 2017 Brainy Education. All rights reserved.
//

import UIKit

class MainStreetViewController: UIViewController {
    var buttonDict: [String: UIButton] = [:]

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
        let scrollView: UIScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300))
        scrollView.contentSize = CGSize(width: 18000, height: 300)
        let containerView: UIView = UIView()
        scrollView.addSubview(containerView)
        self.view.addSubview(scrollView)
        var containerOffset: CGFloat = 0
//        scrollView.addSubview(<#T##view: UIView##UIView#>)
        
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
                    let calculatedWidth = ((image?.size.height)! / 300) * (image?.size.width)!
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: containerOffset, y: 0, width: calculatedWidth, height: 300)
                    containerView.addSubview(imageView)

                    containerOffset += calculatedWidth
                    
                    if (containerOffset == calculatedWidth) { // temporary so we only debug the first picture
                        for currentButton in currentPictureXML.children {
                            if let currentButtonXML = currentButton as? XMLElement {
                                if let widthS = currentButtonXML.attribute(by: "android:layout_width"),
                                    let heightS = currentButtonXML.attribute(by: "android:layout_height") {
                                    
                                    let buttonWidth = widthS.text.dpToCGFloat()
                                    let buttonHeight = heightS.text.dpToCGFloat()
                                    
                                    let marginLeft = currentButtonXML.attribute(by: "android:layout_marginLeft")?.text
                                    let marginTop = currentButtonXML.attribute(by: "android:layout_marginTop")?.text
                                    let marginRight = currentButtonXML.attribute(by: "android:layout_marginRight")?.text
                                    let marginDown = currentButtonXML.attribute(by: "android:layout_marginDown")?.text
                                    
                                    var xOffset: CGFloat = 0
                                    var yOffset: CGFloat = 0
                                    
                                    if let leftM = marginLeft {
                                        xOffset = leftM.dpToCGFloat()
                                    }
                                    
                                    if let rightM = marginRight {
                                        yOffset = rightM.dpToCGFloat()
                                    }

                                    
                                    let buttonDictKey = currentButtonXML.attribute(by: "android:id")?.text ?? "Unknown"
                                    let button = UIButton(type: .roundedRect)
                                    button.setTitle(buttonDictKey, for: .normal)
                                    button.layer.backgroundColor = UIColor.blue.withAlphaComponent(0.5).cgColor
                                    button.frame = CGRect(x: xOffset, y: yOffset, width: buttonWidth, height: buttonHeight)
                                    button.accessibilityLabel = currentButtonXML.attribute(by: "android:tag")?.text
                                    
                                    buttonDict[buttonDictKey] = button
                                    
                                    self.view.addSubview(button)
                                    
                                }
                            }

                    }
                    
                    }
//                    break
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

extension String {
    func dpToCGFloat() -> CGFloat {
        let newStr = self.replacingOccurrences(of: "dp", with: "")
        return CGFloat((newStr as NSString).floatValue)
    }
}
