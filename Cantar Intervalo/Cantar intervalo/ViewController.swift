//
//  ViewController.swift
//  processando-audio
//
//  Created by Macintosh on 28/01/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import UIKit
import Pitchy

class ViewController: UIViewController {

    // Recording sample rate.
    let sampleRate : Float = 44100.0
    
    
    // Number of samples used for each FFT.
    let desiredNumSamplesFFT = 4096
    // FFT size is desiredNumSamplesFFT * paddingfactor, accounting for zero-padding
    let paddingFactor = 2
    
    // Number of frames a note has to be maintained before it's processed.
    let desiredNotePersistence = 4
    // Maximum number of frames, without dectecting a maintained note, before the answer is considered wrong.
    let maximumFramesNumber = 24 // Around 2.2 seconds, with 4096 samples
    
    // Tolerated cent offset for singed note. It's an approximation, actual tolerance can be lower due to FFT's resolution.
    let centOffsetTolerance : Double = 20.0
    
    
    // Intantied audio engine for recording and callback. See viewDidLoad()
    var audioInput: TempiAudioInput!
    
    // Stores detected frequencies over consecutive frames.
    //var freqsOverTime: [Float] = []
    
    // Buffer, acummulates callback samples until the desired number
    var accumulatedSamples: [Float] = []
    
    // Stores for how many frames has the last note been maintained.
    var currentPersistence = 0
    
    // Stores for how many frames has the current recording session has lasted.
    var currentFramesNumber = 0
    
    // Stores currently maintained pitch index (index is based on Pitchy's library, with A440Hz as 0.
    var currentPitchIndex : Int?

    
    
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var repeatOutlet: UIButton!
    @IBOutlet weak var recordOutlet: UIButton!
    
    
    
    @IBAction func repeatButton(_ sender: Any) {
    }
    
    
  
    @IBAction func recordButton(_ sender: Any) {
        audioInput.startRecording()
        setRecordingState(recordingFlag: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instancia o engine de audio, passando a funçao gotSomeAudio() para ser executada em callback.
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: sampleRate, numberOfChannels: 1)
        
        //DEBUGGING
        //let pitch = try! Pitch(frequency: 440.0)
        //debugLabel.text = "\(pitch.note.index)"
        //checkBufferDuration()
        
        setRecordingState(recordingFlag: false)
    }
    
    func gotSomeAudio(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        
        // Add received samples to accumulated buffer.
        accumulatedSamples += samples
        let accumulatedCount = accumulatedSamples.count
        
        
        // When the accumulated buffer size reaches the desired value, process data.
        if accumulatedCount >= desiredNumSamplesFFT {
            
            assert(accumulatedCount == desiredNumSamplesFFT, "Should not be bigger!")
            
            // DEBUGGING
            // debugLabel.text = "\(numberOfFrames)"
            //debugLabel.text = "\(accumulatedCount)"
            
            // Updates frames counter.
            currentFramesNumber += 1
            
            // FFT calculation
            var magnitudes = calculateFFT(size: accumulatedCount*paddingFactor)
            
            // Pitch detection
            let newPitch = detectPitch(fftMagnitudes: &magnitudes, numOfBins: accumulatedCount, startFreq: 100.0, endFreq: 1200.0, maxNumberOfProducts: 3)
            
            // Updates note memory state.
            if updateNoteMemory(newPitch: newPitch) {
                // If a note has been maintained, recording should stop.
                audioInput.stopRecording()
                DispatchQueue.main.async {
                    self.setRecordingState(recordingFlag: false)
                }
                // Compares note memory to the exercise answer.
                if (compareToExpected(expectedPitchIndex: 4)) {
                    correctAnswerReceived()
                }
                else {
                    wrongAnswerReceived()
                }
            }
            
            // If maximum recording time has passed with no maintained note being identified, answer is also considered wrong.
            else if currentFramesNumber > maximumFramesNumber {
                audioInput.stopRecording()
                DispatchQueue.main.async {
                    self.setRecordingState(recordingFlag: false)
                }
                wrongAnswerReceived()
            }
            
        }
        
    }
    
    func correctAnswerReceived() {
        DispatchQueue.main.async {
            self.debugLabel.text = "Right!"
        }
        currentPitchIndex = nil
        currentPersistence = 0
        currentFramesNumber = 0
    }
    
    func wrongAnswerReceived() {
        DispatchQueue.main.async {
            self.debugLabel.text = "Wrong!"
            
        }
        // DEBUG
        if self.currentPitchIndex == nil {
            self.freqLabel.text = "Nenhuma"
        }
        else {
            self.freqLabel.text = "\(self.currentPitchIndex!)"
        }
        currentPitchIndex = nil
        currentPersistence = 0
        currentFramesNumber = 0
    }
    
    
    func updateNoteMemory(newPitch: Pitch) -> Bool {
        /* Compares received pitch with current note memory, updating the program state. Returns true if currentPitchIndex has been maintained for desiredNotePersistence, and false otherwise.
        */
        
        // If received pitch is not close enough to a note (as established by centOffsetTolerance), resets note memory to having no pitch maintained.
        if newPitch.offsets.closest.cents > centOffsetTolerance {
            currentPitchIndex = nil
            currentPersistence = 0
        }
        // If a note has been detected and note memory is empty, or pitch memory exists but doesn't match the new note, update currentPitchIndex with the new note and start counting the persistence.
        else if currentPitchIndex == nil || currentPitchIndex! != newPitch.note.index {
            currentPitchIndex = newPitch.note.index
            currentPersistence = 1
        }
        // If a note has been detected and it matches current note memory, update persistence count.
        // The condition is just for clarity, as it's the only possible scenario if the other conditions are not true.
        else if newPitch.note.index == currentPitchIndex! {
            currentPersistence += 1
            // If persistence count reaches the desired threshold, resets state and returns true, indicating that newPitch has been maintained for desiredNotePersistence frames.
            if currentPersistence >= desiredNotePersistence {
                return true
            }
        }
        return false
        
    }
    
    func compareToExpected (expectedPitchIndex: Int) -> Bool {
        // Simple function that compares maintained and expected (excercise answer) pitch.
        // An octave lower or higher is allowed for the maintained pitch, due to singing range limitations.
        
        assert(currentPitchIndex != nil, "Can't compare to nil!")
        
        return expectedPitchIndex == currentPitchIndex! || expectedPitchIndex == currentPitchIndex! + 12 || expectedPitchIndex == currentPitchIndex! - 12
    }
    

    func setRecordingState (recordingFlag: Bool) {
        // Enable or disable buttons accordingly, depending on whether the app is currently recording or not.
        recordOutlet.isEnabled = !recordingFlag
    }
    
    
    func calculateFFT(size: Int) -> [Float] {
        // Calculate FFT of the accumulatedSamples buffer, resetting it afterwards. Returns array of bin magnitudes, converted to decibels.
        let fft = TempiFFT(withSize: size, sampleRate: sampleRate)
        fft.windowType = TempiFFTWindowType.hanning
        
        // Add zero padding to accumulated samples.
        accumulatedSamples.append(contentsOf: Array(repeating: 0, count: size - accumulatedSamples.count))
        
        // Calculates fft using TempiFFt.
        fft.fftForward(accumulatedSamples)
        
        // Resets accumulatedSamples buffer.
        accumulatedSamples = []
        //return fft.getMagnitudes()
        return fft.getDBMagnitudes()
    }
    
    
    func detectPitch(fftMagnitudes: inout [Float], numOfBins: Int, startFreq: Float, endFreq: Float, maxNumberOfProducts: Int) -> Pitch {
        /* Performs pitch detection on a given FFT output, using the Harmonic Product Spectrum technique.
         fftMagnitudes: FFT output, magnitudes must be logarithmically scaled.
         numOfBins: FFT input vector length. (fftMagnitudes has half this size, since from numOfBins/2 + 1 onwards the FFT information is redundant for real inputs and they're discarded)
         startFreq and endFreq: Define minimum range of frequencies considered. They define a upper bound on the number of downsamples/products used in calculation.
         maxNumberOfProducts: If provided, defines another ceiling on number of downsamples/products used in calculation.
         
         Returns detected pitch, instantied with the Pitchy library, from the detected fundamental frequency.
        */
        
        // Gets the FFT index for startFreq, rounded down to the nearest bin.
        let startIndex : Int = Int(floorf(Float(numOfBins)*startFreq/sampleRate))
        // Gets the FFT index for endFreq, rounded up to the nearest bin.
        let endIndex : Int = Int(ceilf(Float(numOfBins)*endFreq/sampleRate))


        // Removes elements from fftMagnitudes before startIndex, and stores new size.
        //let reducedFFTSize = numOfBins - startIndex
        
        //fftMagnitudes.removeSubrange(0..<startIndex)
        
        
        let numberOfProducts = maxNumberOfProducts // For now.
        
        // Initialize spectrum with elements from reduced fftMagnitudes corresponding to the considered frequency range.
        var harmonicProductSpectrum = Array(fftMagnitudes.prefix(upTo: endIndex+1))
        
        // Loops through each downsample
        for k in 2...numberOfProducts {
            // Pointwise sum harmonic spectrum with the downsampled reduced fftMagnitudes.
            // Since magnitudes are logarithmically scaled, this corresponds to a product in linear scale.
            for i in startIndex...endIndex {
                harmonicProductSpectrum[i] += fftMagnitudes[k*i]
            }
        }
        
        // Find harmonic product spectrum peak.
        let peakMag = harmonicProductSpectrum[startIndex...].max()
        let peakIndex = harmonicProductSpectrum.index(of: peakMag!)
        // Calculate the corresponding frequency.
        let freq : Float = sampleRate/Float(numOfBins) * Float(peakIndex!)
        
        return try! Pitch(frequency: Double(freq))
    }
 
    /*
     
    func detectFrequency(fftMagnitudes: [Float], numOfBins: Int) -> Float {
        /* Performs frequency detection on a given FFT output, using peak bin magnitude and parabolic interpolation.
         Assumes fftMagnitudes values are scaled to decibels, and numOfBins is equal to the FFT input vector's length (fftMagnitudes has half this size, since from numOfBins/2 + 1 onwards the FFT information is redundant for real inputs)
        */
        
        // Get peak magnitude and index from output.
        let peakMag = fftMagnitudes.max()
        let peakIndex = fftMagnitudes.index(of: peakMag!)
        
        // Perform parabolic interpolation:
        let magBefore = fftMagnitudes[peakIndex!-1]
        let magAfter = fftMagnitudes[peakIndex!+1]
        let indexOffset : Float = 1.0/2.0 * (magBefore - magAfter)/(magBefore - 2*peakMag! + magAfter)
        let freq: Float = sampleRate/Float(numOfBins) * (Float(peakIndex!) + indexOffset)
        
        return freq
    }
    */
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
}


func calculateMedian(array: [Float]) -> Float {
    // Helper function that calculates median of Float array.
    let sorted = array.sorted()
    
    if sorted.count % 2 == 0 {
        return (array[sorted.count/2] + array[sorted.count/2 - 1])/2.0
    }
    else {
        return array[sorted.count/2]
    }
}





