//
//  ViewController.swift
//  TesteEmissaoDeNota
//
//  Created by André Cardozo on 23/01/2021.
//  Copyright © 2021 Rafael Melo. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var answer: UILabel!
    let noteArray = ["45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68"]
    
    var baseNote : Int = 0
    var interval : Int = 0
    var nextNote : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Options(_ sender: UIButton) {
    
    let noteInterval = Int (sender.tag + 1)
        
        if noteInterval == interval{
            answer.text = "Correto"
            print("certo")
            
        }else{
            answer.text = "Errado"
            print("errado")
        }
    
    }
    
    @IBAction func RepeatInterval(_ sender: UIButton) {
   
        let currentInterval = CreateInterval(state: false)
        baseNote = currentInterval.0
        nextNote = currentInterval.2
        PlayNote(currentNote: baseNote)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false){(_) in
            self.PlayNote(currentNote: self.nextNote)
            
        }
    }
    
    @IBAction func EmitNewNote(_ sender: UIButton) {
    
        let currentInterval = CreateInterval(state:true)
        print(currentInterval.0)
        print(currentInterval.1)
        print(currentInterval.2)
        baseNote = currentInterval.0
        nextNote = currentInterval.2
        PlayNote(currentNote: baseNote)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false){(_) in
            self.PlayNote(currentNote: self.nextNote)
            
        }
    
    }
    
    func CreateInterval(state: Bool) -> (Int,Int,Int){
        
        if state == true{
            baseNote = Int(arc4random_uniform(12)) //Make a note between A2 and A4
            interval = Int(arc4random_uniform(12)+1)  //Make an interval between Minor second to a Perfect Octave
            nextNote = interval + baseNote
        }
        return (baseNote,interval,nextNote)
    }
    
    func PlayNote(currentNote: Int){
        
        if let soundURL = Bundle.main.url(forResource: noteArray[currentNote], withExtension: "wav") {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            // Play
            AudioServicesPlaySystemSound(mySound);
            }
    }
    
}


