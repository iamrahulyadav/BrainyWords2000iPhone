//
//  MainStreetViewController.swift
//  Brainy Words 2000
//
//  Created by Numeric on 12/23/17.
//  Copyright © 2017 Brainy Education. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MainStreetViewController: UIViewController, UIScrollViewDelegate {
    var imageViews: [String: UIImageView] = [:]
    var buttonDict: [String: UIButton] = [:]
    var scrollView: UIScrollView!
    var audioPlayer: AVAudioPlayer?

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
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300))
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        scrollView.isExclusiveTouch = true
        scrollView.canCancelContentTouches = true
        //        scrollView.da
        //        scrollView.adjustedContentInset = false
        scrollView.delegate = self
        
        scrollView.contentSize = CGSize(width: 15804, height: 300)
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
                    
                    let image = UIImage(named: normalizedImageName!)!
                    let calculatedWidth = (300 * image.size.width) / image.size.height
                    print("image size is: \(image.size), height: 300, width: \(calculatedWidth)")
                    
                    let imageContainerView = UIView()
                    imageContainerView.frame = CGRect(x: containerOffset, y: 0, width: calculatedWidth, height: 300)
                    imageContainerView.isUserInteractionEnabled = true
                    
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: 0, y: 0, width: calculatedWidth, height: 300)
                    imageView.isUserInteractionEnabled = true
                    imageViews[imageName ?? "Unknown"] = imageView
                    imageContainerView.addSubview(imageView)
                    
                    containerView.addSubview(imageContainerView)
                    
                    
                    for currentButton in currentPictureXML.children {
                        // let currentButton = currentPictureXML.children[1]
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
                                if let topM = marginTop {
                                    yOffset = topM.dpToCGFloat()
                                }
                                if let rightM = marginRight {
                                    xOffset = calculatedWidth - rightM.dpToCGFloat()
                                }
                                if let bottomM = marginDown {
                                    yOffset = 300 - bottomM.dpToCGFloat()
                                }

                                let buttonDictKey = currentButtonXML.attribute(by: "android:id")?.text ?? "Unknown"
                                let button = UIButton(type: .roundedRect)
                                button.isEnabled = true
                                button.setTitle(buttonDictKey, for: .normal)
                                button.layer.backgroundColor = UIColor.blue.withAlphaComponent(0.5).cgColor
                                button.frame = CGRect(x: containerOffset + xOffset, y: yOffset, width: buttonWidth, height: buttonHeight)
                                button.accessibilityLabel = currentButtonXML.attribute(by: "android:tag")?.text
                                button.addTarget(self, action: #selector(buttonTappedToPlayWordSound(sender:)), for: .touchUpInside)
                                buttonDict[buttonDictKey] = button
                                
                                // imageContainerView.addSubview(button)
                                scrollView.insertSubview(button, aboveSubview: imageContainerView)
                            }
                        }
                    }
                    containerOffset += calculatedWidth
                }
            }
        } catch let error {
            print("Failed to parse XML. \(error)")
        }
        
        print("In the end, the added width in total is \(containerOffset)")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @objc func buttonTappedToPlayWordSound(sender: UIButton) {
        print("Tapped button \(sender) to play sound")
        if let audioPath = sender.accessibilityLabel {
            print("Tapped button corresponds to sound: \(audioPath) to play sound")
            playSound(soundName: audioPath)
        }
    }
    
    func playSound(soundName: String) {
        let path = "assets/\(soundName)"
        guard let mp3Path = Bundle.main.path(forResource: path, ofType: "mp3") else {
            return
        }
        let mp3FileURL = NSURL(fileURLWithPath: mp3Path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: mp3FileURL as URL)
//            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error {
            print("Failed to play audio. \(error)")
        }
    }

    
    
    
}

extension String {
    func dpToCGFloat() -> CGFloat {
        let newStr = self.replacingOccurrences(of: "dp", with: "")
        return CGFloat((newStr as NSString).floatValue)
    }
}
