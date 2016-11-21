//
//  MyUtils.swift
//  Autumn's Song
//
//  Created by Eder Rengifo on 29/01/15.
//  Copyright (c) 2015 Eder Rengifo. All rights reserved.
//

import Foundation
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(_ filename: String) {
    let resourceUrl = Bundle.main.url(
        forResource: filename, withExtension: nil)
    guard let url = resourceUrl else {
        print("Could not find file: \(filename)")
        return
    }
    
    do {
        try backgroundMusicPlayer = AVAudioPlayer(contentsOf: url)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    } catch {
        print("Could not create audio player!")
        return
    }
}



    
    
