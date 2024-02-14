//
//  ItemSet.swift
//  Fieldomation
//
//  Created by Devin Rogers on 1/9/24.
//

import Foundation
import AVFoundation

@Observable class ItemSet {
    var itemSet : Set<String> = []
    var player: AVAudioPlayer?
    
    func insert(str: String) {
        itemSet.insert(str)
        playSound()
    }
    
    func toString() -> String {
        return itemSet.description
    }
    
    func getSet() -> Set<String> {
        return itemSet
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "scantone", withExtension: "m4a") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}
