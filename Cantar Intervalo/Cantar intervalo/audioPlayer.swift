//
//  audioPlayer.swift
//  Cantar intervalo
//
//  Created by Macintosh on 30/01/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import UIKit
import AVFoundation

// Wraps AVAudioPlayer for note playing. Only playAudio needs to be interacted with.
class AudioPlayerWrapper : NSObject, AVAudioPlayerDelegate {
    
    // Instantiates AVAudioPlayer
    var audioPlayer: AVAudioPlayer?
    
    // Pitchy index -24 (A2) corresponds to noteArray index 0
    let offsetFromPitchyIndex = 24
    
    func playAudio (notePitchyIndex: Int) {
    // Plays note corresponding to the provided index.
        
        // Gets corresponding URL for the note.
        let noteFilename = notesArray[convertToNoteArrayIndex(notePitchyIndex: notePitchyIndex)]
        let noteFileURL = Bundle.main.url(forResource: noteFilename, withExtension: "wav", subdirectory: "notas")
        assert(noteFileURL != nil, "Couldn't find file!")
        
        // Sets up audio session and audio player.
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: noteFileURL!)
            audioPlayer?.delegate = self
            // This is needed because tempiAudioInput changes the sharedInstance object.
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            assert(false, "Could not play sound!")
        }
        // Plays the note.
        audioPlayer?.play()
    }
    
    
    func convertToNoteArrayIndex (notePitchyIndex: Int) -> Int {
        // Helper function that converts from Pitchy index to noteArray index.
        assert(notePitchyIndex >= -offsetFromPitchyIndex && notePitchyIndex <= notesArray.count - offsetFromPitchyIndex - 1, "Note outside range!")
        return notePitchyIndex + offsetFromPitchyIndex
    }
}
