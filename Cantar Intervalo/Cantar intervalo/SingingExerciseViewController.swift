//
//  SingingExerciseViewController.swift
//  processando-audio
//
//  Created by Macintosh on 28/01/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import UIKit
import Pitchy
import CoreData

// Possible states for the interval singing exercise.
enum IntervalSingingStates {
    case startup // Before first exercise begins.
    case setup // Setting up exercise.
    case active // Exercise active and waiting for recording.
    case recording // Recording answer to exercise.
    case right // Correct answer received.
    case wrong // Wrong answer received.
}

class SingingExerciseViewController: UIViewController {
    
    // Temporary, just for debugging.
    var results = [ExerciseResult]()

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
    
    
    // Instanstied audio engine for recording and callback. See viewDidLoad()
    var audioInput: TempiAudioInput!
    
    // Instantied audio engine for playing notes.
    var audioPlayer: AudioPlayerWrapper?
    
    // Buffer, acummulates callback samples until the desired number
    var accumulatedSamples: [Float] = []
    
    // Stores for how many frames has the last note been maintained.
    var currentPersistence = 0
    
    // Stores for how many frames has the current recording session has lasted.
    var currentFramesNumber = 0
    
    // Stores currently maintained pitch index (index is based on Pitchy's library, with A440Hz as 0.
    var currentPitchIndex : Int?
    
    // Stores current reference and target notes as Pitchy indexes. The default value is not used.
    var targetNote : Int = 0
    var referenceNote : Int = 0
    
    // Stores program state. The default value is not needed, since it's reinitialized after.
    var intervalSingingState : IntervalSingingStates = .startup
    
    // Context for core data storage.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var repeatOutlet: UIButton!
    @IBOutlet weak var recordOutlet: UIButton!
    @IBOutlet weak var answerOutlet: UIButton!
    
    
    
    @IBAction func repeatButton(_ sender: Any) {
        switch intervalSingingState {
        case .active:
            // Reference note can be repeated arbitrarily, on active, right or wrong states.
            audioPlayer!.playAudio(noteIndex: referenceNote)
        case .right:
            // Same as .active.
            audioPlayer!.playAudio(noteIndex: referenceNote)
        case .wrong:
            // Same as .active.
            audioPlayer!.playAudio(noteIndex: referenceNote)
        default:
            assert(false, "Should not be able to press repeat button!")
        }
    }
    
    @IBAction func answerButton(_ sender: Any) {
        switch intervalSingingState {
        case .right:
            // Listening to the target note is allowed after answering, regardless of getting it right or wrong.
            audioPlayer!.playAudio(noteIndex: targetNote)
        case .wrong:
            // Same as case .right.
            audioPlayer!.playAudio(noteIndex: targetNote)
        default:
            assert(false, "Should not be able to press answer button!")
        }
    }
    
  
    @IBAction func recordButton(_ sender: Any) {
        
        switch intervalSingingState {
        case .startup:
            // At startup, button is "Começar". If pressed, changes the program state to active.
            changeIntervalSingingState(state: .setup)
        case .active:
            // If program state is active, recording starts when the button is pressed.
            changeIntervalSingingState(state: .recording)
            
        case .right:
            // If exercised has been answered, button is "Próximo". If pressed, change program state to active.
            changeIntervalSingingState(state: .setup)
        
        case .wrong:
            // Same as case .right.
            changeIntervalSingingState(state: .setup)
            
        default:
            assert(false, "Should not be able to press record button while recording or setting up!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instancia o engine de audio, passando a funçao gotSomeAudio() para ser executada em callback.
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: sampleRate, numberOfChannels: 1)
        
        // Instantiates audioPlayer.
        audioPlayer = AudioPlayerWrapper()
        
        
        // Initializes program state as startup.
        changeIntervalSingingState(state: .startup)
    }
    
    func changeIntervalSingingState(state: IntervalSingingStates) {
        // Changes program state and updates buttons and labels accordingly.
        intervalSingingState = state
        switch state {
        case .startup:
            // These are not needed, since default values can be established.
            recordOutlet.isEnabled = true // At this point, recordOutlet reads "Começar"
            repeatOutlet.isEnabled = false
            answerOutlet.isEnabled = false
        case .setup:
            // Disables all buttons while setting up.
            recordOutlet.isEnabled = false
            repeatOutlet.isEnabled = false
            answerOutlet.isEnabled = false
            // Sets up randomized exercise, changing state to active in the process.
            setupExercise()
        case .active:
            // setupExercise() already does the work, no more updates are necessary.
            ()
        case .recording:
            startRecordingWrapper()
        case .right:
            rightAnswerReceived()
        case .wrong:
            wrongAnswerReceived()
        }
    }
    
    func setupExercise() {
        // Sets up randomized exercise.
        
        // Sorts interval.
        let intervalIndex = Int( arc4random_uniform(UInt32(intervalsArray.count)) )
        
        
        // Sorts target note, converting it to Pitchy index. Sorting should be careful such that referenceNote is also inside the allowed range.
        targetNote = Int(arc4random_uniform(UInt32(
            notesArray.count - (intervalIndex+1)
        ))) + (intervalIndex+1) + firstNotePitchyIndex
        
        // Calculates reference from target, according to the interval.
        referenceNote = targetNote - (intervalIndex+1)
        
        // Updates labels.
        upperLabel.text = "Cante o intervalo pedido."
        upperLabel.textColor = UIColor.white
        intervalLabel.alpha = 1.0
        intervalLabel.text = intervalsArray[intervalIndex]
        intervalLabel.textColor = UIColor.white
        
        // Updates buttons.
        answerOutlet.alpha = 0.0
        answerOutlet.isEnabled = false
        repeatOutlet.alpha = 1.0
        repeatOutlet.isEnabled = true
        recordOutlet.setTitle("Gravar", for: .normal)
        recordOutlet.isEnabled = true
        
        changeIntervalSingingState(state: .active)
        
        // Plays reference note.
        audioPlayer!.playAudio(noteIndex: referenceNote)
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
                // Compares note memory to the exercise answer.
                if (compareToExpected(expectedPitchIndex: targetNote)) {
                    DispatchQueue.main.async { self.changeIntervalSingingState(state: .right) }
                }
                else {
                    DispatchQueue.main.async { self.changeIntervalSingingState(state: .wrong) }
                }
            }
            
            // If maximum recording time has passed with no maintained note being identified, answer is also considered wrong.
            else if currentFramesNumber > maximumFramesNumber {
                audioInput.stopRecording()
                DispatchQueue.main.async { self.changeIntervalSingingState(state: .wrong) }
            }
            
        }
        
    }
    
    func startRecordingWrapper() {
        // Called when program changes to recording state.
        
        // Disables all buttons while recording.
        recordOutlet.isEnabled = false
        repeatOutlet.isEnabled = false
        answerOutlet.isEnabled = false // Just for clarification, since answerOutlet is already disabled.
        
        // Resets note memory and samples buffer.
        currentPitchIndex = nil
        currentPersistence = 0
        currentFramesNumber = 0
        accumulatedSamples = []
        
        // Starts recording
        audioInput.startRecording()
    }
    
    func rightAnswerReceived() {
        // Called when program changes to right (answer) state.
        
        DispatchQueue.main.async {
            // Updates labels.
            self.upperLabel.text = "Correto! :)"
            self.upperLabel.textColor = UIColor.init(red: 0.670, // 171/255
                                                     green: 1.0, // 255/255
                                                     blue: 0.365, // 93/255
                                                     alpha: 1)
            self.intervalLabel.textColor = UIColor.init(red: 0.670, green: 1.0, blue: 0.365, alpha: 1)
            
            // Updates buttons.
            self.answerOutlet.alpha = 1.0
            self.answerOutlet.isEnabled = true
            self.repeatOutlet.isEnabled = true
            self.recordOutlet.setTitle("Próximo", for: .normal)
            self.recordOutlet.isEnabled = true
            
            self.saveExerciseResult(result: true)
            
        }
        
    }
    
    func wrongAnswerReceived() {
        // Called when program changes to wrong (answer) state.
        
        DispatchQueue.main.async {
            // Updates labels.
            self.upperLabel.text = "Errado. :("
            self.upperLabel.textColor = UIColor.init(red: 1.0, // 255/255
                                                    green: 0.365, // 255/255
                                                    blue: 0.282, // 93/255
                                                    alpha: 1)
            self.intervalLabel.textColor = UIColor.init(red: 1.0, green: 0.365, blue: 0.282, alpha: 1)
            
            // Updates buttons.
            self.answerOutlet.alpha = 1.0
            self.answerOutlet.isEnabled = true
            self.repeatOutlet.isEnabled = true
            self.recordOutlet.setTitle("Próximo", for: .normal)
            self.recordOutlet.isEnabled = true
            
            self.saveExerciseResult(result: false)
        }
        // DEBUG
        /*
        if self.currentPitchIndex == nil {
            self.freqLabel.text = "Nenhuma"
        }
        else {
            self.freqLabel.text = "\(self.currentPitchIndex!)"
        } */
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
    
    
    
    func calculateFFT(size: Int) -> [Float] {
        // Calculate FFT of the accumulatedSamples buffer, resetting it afterwards. Returns array of bin magnitudes, converted to decibels.
        let fft = TempiFFT(withSize: size, sampleRate: sampleRate)
        fft.windowType = TempiFFTWindowType.hanning
        
        // Add zero padding to accumulated samples.
        accumulatedSamples.append(contentsOf: Array(repeating: 0, count: size - accumulatedSamples.count))
        
        // Calculates fft using TempiFFt.
        fft.fftForward(accumulatedSamples)
        
        // Resets accumulatedSamples buffer. (Not needed, since it's always done before recording.)
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

    func saveExerciseResult(result: Bool) {
        // Saves exercise result as core data.
        let exerciseResult = ExerciseResult(context: context)
        exerciseResult.date = Date()
        exerciseResult.correctInterval = Int16(targetNote-referenceNote-1)
        exerciseResult.exerciseType = ExerciseType.singingExercise.rawValue
        exerciseResult.result = result
        if currentPersistence < desiredNotePersistence {
            exerciseResult.answeredInterval = NO_NOTE_MAINTAINED
        }
        else {
            exerciseResult.answeredInterval = getIntervalIndex(singed: currentPitchIndex!, reference: referenceNote)
        }
        do {
            
            try context.save()
        }
        catch {
            print("Error saving context: \(error)")
        }
    }

    
    @IBAction func debugButtonPressed(_ sender: Any) {
        // Purely for debugging.
        for result in results {
            context.delete(result)
        }
        results.removeAll()
        do {
            try context.save()
        }
        catch {
            print("Error saving context: \(error)")
        }
        
    }
    
    @IBAction func otherDebugButtonPressed(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request : NSFetchRequest<ExerciseResult> = ExerciseResult.fetchRequest()
        
        do {
            results = try context.fetch(request)
        }
        catch {
            print("Error fetching request. \(error)")
        }
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

func getIntervalIndex(singed: Int, reference: Int) -> Int16 {
    let rem = Int16((singed - reference - 1) % 12)
    return rem >= 0 ? rem : rem + 12
}




