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
    var containerOffset: CGFloat = 0

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
        // scrollView.adjustedContentInset = false
        scrollView.delegate = self
        
        scrollView.contentSize = CGSize(width: 15804, height: 300)
        let containerView: UIView = UIView()
        scrollView.addSubview(containerView)
        self.view.addSubview(scrollView)
        // scrollView.addSubview(<#T##view: UIView##UIView#>)
        
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
                                
                                let toRightOf = currentButtonXML.attribute(by: "android:layout_toRightOf")?.text
                                let toLeftOf = currentButtonXML.attribute(by: "android:layout_toLeftOf")?.text

                                var xOffset: CGFloat = 0
                                var yOffset: CGFloat = 0
                                
                                if let rightM = toRightOf as? String, let referenceButton = buttonDict[rightM] {
                                    print("referencing other (to the right) button \(referenceButton)")
                                    xOffset = referenceButton.frame.origin.x - containerOffset + referenceButton.frame.size.width
                                }
                                
                                if let leftM = toLeftOf as? String, let referenceButton = buttonDict[leftM] {
                                    print("referencing other (to the left) button \(referenceButton)")
                                    // this is unlikely to be correct
                                    xOffset = referenceButton.frame.origin.x - containerOffset
                                }

                                
                                if let leftM = marginLeft {
                                    xOffset += leftM.dpToCGFloat()
                                }
                                if let rightM = marginRight {
                                    xOffset += calculatedWidth - rightM.dpToCGFloat()
                                }
                                
                                if let topM = marginTop {
                                    yOffset += topM.dpToCGFloat()
                                }
                                if let bottomM = marginDown {
                                    yOffset += 300 - bottomM.dpToCGFloat()
                                }

                                let buttonDictKey = currentButtonXML.attribute(by: "android:id")?.text ?? "Unknown"
                                let button = UIButton(type: .roundedRect)
                                button.isEnabled = true
                                button.setTitle(buttonDictKey, for: .normal)
                                button.layer.backgroundColor = UIColor.blue.withAlphaComponent(0.5).cgColor
                                button.frame = CGRect(x: containerOffset + xOffset, y: yOffset, width: buttonWidth, height: buttonHeight)
                                
                                if let onTapAction = currentButtonXML.attribute(by: "android:onClick")?.text {
                                    button.accessibilityLabel = currentButtonXML.attribute(by: "android:tag")?.text
                                    if onTapAction == "playSound" {
                                        button.addTarget(self, action: #selector(buttonTappedToPlayWordSound(sender:)), for: .touchUpInside)
                                    } else if onTapAction == "openStore" {
                                        button.addTarget(self, action: #selector(buttonTappedToOpenStore(sender:)), for: .touchUpInside)
                                    } else if onTapAction == "openInterior" {
                                        button.addTarget(self, action: #selector(buttonTappedToOpenInterior(sender:)), for: .touchUpInside)
                                    } else {
                                        print("Based on limited XML information, button action unknown.")
                                    }
                                }
                                
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
    
    @objc func buttonTappedToOpenStore(sender: UIButton) {
        if let storePath = sender.accessibilityLabel {
            print("Tapped button corresponds to store: \(storePath)")
        }
    }
    
    @objc func buttonTappedToOpenInterior(sender: UIButton) {
        if let interiorPath = sender.accessibilityLabel {
            print("Tapped button corresponds to interior: \(interiorPath)")
        }
    }
    
    @objc func buttonTappedToPlayWordSound(sender: UIButton) {
        print("Tapped button \(sender) to play sound")
        if let audioPath = sender.accessibilityLabel {
            print("Tapped button corresponds to sound: \(audioPath) to play sound")
            playSound(soundName: audioPath)
        }
    }
    
    func playSound(soundName: String) {
        var path = "assets/\(soundName)".replacingOccurrences(of: ".mp3", with: "") // some files inside the manifist already have the mp3 extension
        if !soundName.contains("/") {
            path = "assets/xtra/HEADINGS/00\(soundName)"
        }

        var mp3Path = ""
        if let tempPath = Bundle.main.path(forResource: path, ofType: "mp3") {
            mp3Path = tempPath
        } else {
            path = "assets/xtra/HEADINGS/00\(soundName)"
            if let tempPathUncategorized = Bundle.main.path(forResource: path, ofType: "mp3") {
                mp3Path = tempPathUncategorized
            } else {
                return
            }
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
    
    func playCategorySound(cat: String) {
        
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = self.view.frame.size.width
        
        if (scrollView.contentOffset.x < CGFloat(0)) {
            scrollView.contentOffset.x = containerOffset - threshold
        } else if (scrollView.contentOffset.x > CGFloat(containerOffset - threshold)) {
            scrollView.contentOffset.x = 0
        }
    }
    
}

extension String {
    func dpToCGFloat() -> CGFloat {
        let newStr = self.replacingOccurrences(of: "dp", with: "")
        return CGFloat((newStr as NSString).floatValue)
    }
}
