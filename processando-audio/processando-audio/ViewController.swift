//
//  ViewController.swift
//  processando-audio
//
//  Created by Macintosh on 28/01/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Recording sample rate.
    let sampleRate : Float = 44100.0
    
    // Intantied audio engine for recording and callback. See viewDidLoad()
    var audioInput: TempiAudioInput!
    
    // Stores detected frequencies over consecutive frames.
    var freqsOverTime: [Float] = []
    
    // Buffer, acummulates callback samples until the desired number
    var accumulatedSamples: [Float] = []
    let desiredNumSamplesFFT = 8192
    
    
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
        
        //DEBBUGING
        //debugLabel.text = "\(freqsOverTime.count)"
        
        let medianPeakFreq = calculateMedian(array: freqsOverTime)
        freqLabel.text = "\(medianPeakFreq)"
        freqsOverTime = []
        
        setRecordingState(recordingFlag: false)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instancia o engine de audio, passando a funçao gotSomeAudio() para ser executada em callback.
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: sampleRate, numberOfChannels: 1)
        
        // DEBUGGING
        //checkBufferDuration()
        
        setRecordingState(recordingFlag: false)
    }
    
    func gotSomeAudio(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        
        // Add received samples to accumulated buffer.
        accumulatedSamples += samples
        let accumulatedCount = accumulatedSamples.count
        
        
        // When the accumulated buffer size reaches the desired value, process data.
        if accumulatedCount >= desiredNumSamplesFFT {
            
            // DEBUGGING
            // debugLabel.text = "\(numberOfFrames)"
            //debugLabel.text = "\(accumulatedCount)"
            
            // FFT calculation
            var magnitudes = calculateFFT(size: accumulatedCount)
            
            // Frequency detection
            //let freq = detectFrequency(fftMagnitudes: magnitudes, numOfBins: accumulatedCount)
            
            let freq = detectPitch(fftMagnitudes: &magnitudes, numOfBins: accumulatedCount, startFreq: 100.0, endFreq: 1200.0, maxNumberOfProducts: 3)
            freqsOverTime.append(freq)
            
        }
        
    }
    

    func setRecordingState (recordingFlag: Bool) {
        // Enable or disable buttons accordingly, depending on whether the app is currently recording or not.
        recordOutlet.isEnabled = !recordingFlag
        stopOutlet.isEnabled = recordingFlag
    }
    
    
    func calculateFFT(size: Int) -> [Float] {
        // Calculate FFT of the accumulatedSamples buffer, resetting it afterwards. Returns array of bin magnitudes, converted to decibels.
        let fft = TempiFFT(withSize: size, sampleRate: sampleRate)
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(accumulatedSamples)
        accumulatedSamples = []
        //return fft.getMagnitudes()
        return fft.getDBMagnitudes()
    }
    
    
    func detectPitch(fftMagnitudes: inout [Float], numOfBins: Int, startFreq: Float, endFreq: Float, maxNumberOfProducts: Int) -> Float {
        /* Performs pitch detection on a given FFT output, using the Harmonic Product Spectrum technique.
         fftMagnitudes: FFT output, magnitudes must be logarithmically scaled.
         numOfBins: FFT input vector length. (fftMagnitudes has half this size, since from numOfBins/2 + 1 onwards the FFT information is redundant for real inputs and they're discarded)
         startFreq and endFreq: Define minimum range of frequencies considered. They define a upper bound on the number of downsamples/products used in calculation.
         maxNumberOfProducts: If provided, defines another ceiling on number of downsamples/products used in calculation.
         
         Returns detected pitch.
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
        
        return freq
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
    
    //DEBBUGING (function has to be defined inside class)
    //debugLabel.text = "\(sorted.count)"
    
    if sorted.count % 2 == 0 {
        return (array[sorted.count/2] + array[sorted.count/2 - 1])/2.0
    }
    else {
        return array[sorted.count/2]
    }
}





