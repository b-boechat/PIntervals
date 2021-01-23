//
//  ViewController.swift
//  TesteEmissaoDeNota
//
//  Created by André Cardozo on 23/01/2021.
//  Copyright © 2021 Rafael Melo. All rights reserved.
//

import UIKit
import AudioToolbox

var sequence : MusicSequence? = nil
var track : MusicTrack? = nil

class ViewController: UIViewController {

    
    var musicSequenceStatus: OSStatus = NewMusicSequence(&sequence)
    var musicTrack = MusicSequenceNewTrack(sequence!, &track)
    var time = MusicTimeStamp(2.0)
    var note = MIDINoteMessage(channel: 0,
                               note: 69,
                               velocity: 255,
                               releaseVelocity: 0,
                               duration: 5.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func EmitirNota(_ sender: UIButton) {
        
        CreateInterval()
        PlayNote()
        
    }
    func CreateInterval(){
        
        var baseNote : UInt8 = 0
        var interval : UInt8 = 0
        var nextNote : UInt8 = 0
        baseNote = UInt8(arc4random_uniform(24)+45)
        interval = UInt8(arc4random_uniform(12)+1)
        nextNote = interval + baseNote
        print (baseNote)
        print (interval)
        print(nextNote)
        var notes: [UInt8] = [baseNote,nextNote]
        time = 0
        for index:Int in 0...1 {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 64,
                                       releaseVelocity: 1,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 2
        }
        
    }
    
    func PlayNote(){
        
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)
        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
        
    }

}

