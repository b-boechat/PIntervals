//
//  IdentificationExerciseViewController.swift
//  TesteEmissaoDeNota
//
//  Created by André Cardozo on 23/01/2021.
//  Copyright © 2021 Rafael Melo. All rights reserved.
//

import UIKit
import AudioToolbox

class IdentificationExerciseViewController: UIViewController {
    
    // Context for core data storage.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var answer: UILabel!
    let noteArray = ["45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68"]
    
    var audioPlayer: AudioPlayerWrapper?
    
    var baseNote : Int = 0
    var interval : Int = 0
    var nextNote : Int = 0
    
    @IBOutlet var answerButtonsOutlets: [UIButton]!
    
    
    var exerciseIsActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerButtonsOutlets = answerButtonsOutlets.sorted{$0.tag < $1.tag}
        audioPlayer = AudioPlayerWrapper()
        setupExercise()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Options(_ sender: UIButton) {
    
        if exerciseIsActive {
            let noteInterval = Int (sender.tag + 1)
        
            if noteInterval == interval {
                answer.text = "Correto"
                answer.textColor = UIColor.init(red: 0.670, green: 1.0, blue: 0.365, alpha: 1)
                saveExerciseResult(result: true, answeredInterval: noteInterval)
                //print("certo")
            }
            else {
                answer.text = "Errado"
                answer.textColor = UIColor.init(red: 1.0, green: 0.365, blue: 0.282, alpha: 1)
                saveExerciseResult(result: false, answeredInterval: noteInterval)
                //print("errado")
            }
            answerButtonsOutlets[interval-1].setTitleColor(UIColor.init(red: 0.670, green: 1.0, blue: 0.365, alpha: 1), for: UIControlState.disabled)
            
            for button in answerButtonsOutlets {
                button.isEnabled = false
            }
            
            exerciseIsActive = false
        }
    }
    
    @IBAction func RepeatInterval(_ sender: UIButton) {
   
        let currentInterval = CreateInterval(state: false)
        baseNote = currentInterval.0
        nextNote = currentInterval.2
        audioPlayer!.playAudio(noteIndex: baseNote, isArrayIndex: true)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false){(_) in
            self.audioPlayer!.playAudio(noteIndex: self.nextNote, isArrayIndex: true)
            
        }
    }
    
    @IBAction func EmitNewNote(_ sender: UIButton) {
        setupExercise()
    }
    
    func setupExercise() {
        let currentInterval = CreateInterval(state:true)
        answer.text = "Qual intervalo?"
        answer.textColor = UIColor.white
        //print(currentInterval.0)
        print(currentInterval.1)
        //print(currentInterval.2)
        baseNote = currentInterval.0
        nextNote = currentInterval.2
        exerciseIsActive = true
        for button in answerButtonsOutlets {
            button.isEnabled = true
            button.setTitleColor(UIColor.white, for: UIControlState.disabled)
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
        }
        audioPlayer!.playAudio(noteIndex: baseNote, isArrayIndex: true)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false){(_) in
            self.audioPlayer!.playAudio(noteIndex: self.nextNote, isArrayIndex: true)
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
    
    
    func saveExerciseResult(result: Bool, answeredInterval: Int) {
        // Saves exercise result as core data.
        let exerciseResult = ExerciseResult(context: context)
        exerciseResult.date = Date()
        exerciseResult.correctInterval = Int16(interval)
        exerciseResult.exerciseType = ExerciseType.identificationExercise.rawValue
        exerciseResult.result = result
        exerciseResult.answeredInterval = Int16(answeredInterval)
        do {
            try context.save()
        }
        catch {
            print("Error saving context: \(error)")
        }
    }
    
    /*func PlayNote(currentNote: Int){
        
        if let soundURL = Bundle.main.url(forResource: noteArray[currentNote], withExtension: "wav", subdirectory: "notas") {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            // Play
            AudioServicesPlaySystemSound(mySound);
            }
    }*/
    
}


