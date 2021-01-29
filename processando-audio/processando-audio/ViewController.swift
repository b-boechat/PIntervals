//
//  ViewController.swift
//  processando-audio
//
//  Created by Macintosh on 28/01/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Variável na qual é instanciado o engine para gravaçao. Ver funçao viewDidLoad()
    var audioInput: TempiAudioInput!
    
    // Guarda picos de frequencia da DFT ao longo de instantes de tempo
    var freqsOverTime: [Float] = []
    
    
    var magnitudes: [Float] = []
    
    
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBOutlet weak var recordOutlet: UIButton!
    
    @IBOutlet weak var stopOutlet: UIButton!
    
    
    @IBOutlet weak var freqLabel: UILabel!
    
    
    @IBAction func recordButton(_ sender: Any) {
        audioInput.startRecording()
        setRecordingState(recordingFlag: true)
    }
    
    
    @IBAction func stopButton(_ sender: Any) {
        audioInput.stopRecording()
        
        var meanPeakFreq: Float = 0
        for i in 0...(freqsOverTime.count - 1) {
            meanPeakFreq += freqsOverTime[i]
        }
        meanPeakFreq /= Float(freqsOverTime.count - 1)
        
        freqLabel.text = "\(meanPeakFreq)"
        freqsOverTime = []
        
        setRecordingState(recordingFlag: false)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instancia o engine de audio, passando a funçao gotSomeAudio() para ser executada em callback.
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
        
        // DEBUGGING
        //checkBufferDuration()
        
        setRecordingState(recordingFlag: false)
    }
    
    func gotSomeAudio(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        
        let fft = TempiFFT(withSize: numberOfFrames, sampleRate: 44100.0)
        
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(samples)
        
        let magnitudes = fft.getMagnitudes()
        
        // DEBUGGING
        // debugLabel.text = "\(numberOfFrames)"
        //debugLabel.text = "\(samples.count)"
        
        
        let peak_mag = magnitudes.max()
        let freq : Float = Float(magnitudes.index(of: peak_mag!)!) * Float(44100.0) / Float(numberOfFrames)
        
        freqsOverTime.append(freq)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setRecordingState (recordingFlag: Bool) {
        // Enable or disable buttons accordingly, depending on whether the app is currently recording or not.
        recordOutlet.isEnabled = !recordingFlag
        stopOutlet.isEnabled = recordingFlag
    }

}

