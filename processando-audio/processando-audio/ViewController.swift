//
//  ViewController.swift
//  processando-audio
//
//  Created by Macintosh on 28/01/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var audioInput: TempiAudioInput!
    
    var freqsOverTime: [Float] = []
    
    
    @IBOutlet weak var recordOutlet: UIButton!
    
    @IBOutlet weak var stopOutlet: UIButton!
    
    
    @IBOutlet weak var freqLabel: UILabel!
    
    
    @IBAction func recordButton(_ sender: Any) {
        audioInput.startRecording()
        stopOutlet.isEnabled = true
        recordOutlet.isEnabled = false
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
        
        stopOutlet.isEnabled = false
        recordOutlet.isEnabled = true
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
        
        stopOutlet.isEnabled = false
        recordOutlet.isEnabled = true
    }
    
    func gotSomeAudio(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        
        let fft = TempiFFT(withSize: numberOfFrames, sampleRate: 44100.0)
        
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(samples)
        
        let magnitudes = fft.getMagnitudes()
        let peak_mag = magnitudes.max()
        let freq : Float = Float(magnitudes.index(of: peak_mag!)!) * Float(44100.0) / Float(numberOfFrames)
        
        freqsOverTime.append(freq)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

