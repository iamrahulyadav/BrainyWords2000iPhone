//
//  ViewController.swift
//  Brainy Words 2000
//
//  Created by Numeric on 12/23/17.
//  Copyright © 2017 Brainy Education. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class LogoViewController: UIViewController, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        playSound()
    }
    
    func playSound() {
        let startSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "assets/xtra/HEADINGS/00brainy_words_2000", ofType: "mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: startSound as URL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error {
            print("Failed to play audio. \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func jumpToMainStreetViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainStreetVC = storyboard.instantiateViewController(withIdentifier: "MainStreetViewController") as? MainStreetViewController else {
            return
        }
        self.present(mainStreetVC, animated: false) {
            print("Presented main street view controller")
        }
    }


}

