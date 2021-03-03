//
//  debugFuncs.swift
//  processando-audio
//
//  Created by Macintosh on 28/01/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import Foundation

extension SingingExerciseViewController {
    
    func checkBufferDuration() {
        let bufferDuration = audioInput.audioSession.ioBufferDuration
        debugLabel.text = "\(bufferDuration)"
    }
}

extension StatisticsViewController {
    
    func replaceWithDebugResults(_ resultsAsStruct: [ExerciseResultStruct], removeFirst: Bool = true) {
        
        // Delete previously saved results.
        if (removeFirst) {
            removeResults()
        }
        
        
        
        for resultStruct in resultsAsStruct {
            // Saves exercise results as core data.
            let exerciseResult = ExerciseResult(context: context)
            exerciseResult.date = resultStruct.date
            exerciseResult.exerciseType = resultStruct.exerciseType
            exerciseResult.correctInterval = resultStruct.correctInterval
            exerciseResult.answeredInterval = resultStruct.answeredInterval
            exerciseResult.result = resultStruct.result
            do {
                try context.save()
            }
            catch {
                print("Error saving context: \(error)")
            }
        }
        
        fetchResults()
        
    }
}

struct ExerciseResultStruct {
    // Only for debugging purposes.
    var date: Date
    var exerciseType: Int16
    var correctInterval: Int16
    var answeredInterval: Int16
    var result: Bool
}




let resultsAsStruct1 = [
    ExerciseResultStruct(date: calendar.date(from: DateComponents(timeZone: TimeZone(abbreviation: "BRT"), year: 2021, month: 2, day: 26))!, exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 2, answeredInterval: 3, result: false),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 2, answeredInterval: 3, result: false),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 2, answeredInterval: 2, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 2, answeredInterval: 2, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 2, answeredInterval: 2, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 2, answeredInterval: 2, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 2, answeredInterval: 2, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 2, answeredInterval: 2, result: true),
    
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 1, answeredInterval: 1, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 1, answeredInterval: 1, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 1, answeredInterval: 1, result: false),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 3, answeredInterval: 3, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 4, answeredInterval: 4, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 5, answeredInterval: 1, result: false),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 6, answeredInterval: 6, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 7, answeredInterval: 7, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 8, answeredInterval: 8, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 9, answeredInterval: 9, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 10, answeredInterval: 10, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 11, answeredInterval: 11, result: true),
    ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                         correctInterval: 12, answeredInterval: 12, result: true),
]

let calendar = Calendar.current

let resultsAsStruct2 = [
 ExerciseResultStruct(date: calendar.date(from: DateComponents(timeZone: TimeZone(abbreviation: "BRT"), year: 2021, month: 2, day: 26))!, exerciseType: ExerciseType.singingExercise.rawValue, correctInterval: 1, answeredInterval: 3, result: true),
 ExerciseResultStruct(date: calendar.date(from: DateComponents(timeZone: TimeZone(abbreviation: "BRT"), year: 2021, month: 2, day: 25))!,
 exerciseType: ExerciseType.singingExercise.rawValue, correctInterval: 2, answeredInterval: 3, result: true),
 ExerciseResultStruct(date: calendar.date(from: DateComponents(timeZone: TimeZone(abbreviation: "BRT"), year: 2021, month: 2, day: 24))!,
 exerciseType: ExerciseType.singingExercise.rawValue, correctInterval: 3, answeredInterval: 3, result: true),
 ExerciseResultStruct(date: calendar.date(from: DateComponents(timeZone: TimeZone(abbreviation: "BRT"), year: 2021, month: 2, day: 23))!,
 exerciseType: ExerciseType.singingExercise.rawValue, correctInterval: 4, answeredInterval: 3, result: true),
 ExerciseResultStruct(date: calendar.date(from: DateComponents(timeZone: TimeZone(abbreviation: "BRT"), year: 2021, month: 2, day: 22))!,
 exerciseType: ExerciseType.singingExercise.rawValue, correctInterval: 5, answeredInterval: 3, result: true),
 ]

let resultsAsStruct3 = [ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 1, answeredInterval: 1, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 2, answeredInterval: 3, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 3, answeredInterval: 4, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 4, answeredInterval: 1, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 5, answeredInterval: 1, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 6, answeredInterval: 6, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 7, answeredInterval: 7, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 8, answeredInterval: 8, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 9, answeredInterval: 9, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 10, answeredInterval: 10, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 11, answeredInterval: 11, result: false),
                            ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.identificationExercise.rawValue,
                                                 correctInterval: 12, answeredInterval: 12, result: false)
]

let resultsAsStruct4 = [ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 1, result: true),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 2, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 3, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 4, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 5, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 6, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 7, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 8, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 9, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 10, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 11, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 1, answeredInterval: 12, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 2, answeredInterval: 3, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 3, answeredInterval: 4, result: false),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 4, answeredInterval: 1, result: false),
                        ExerciseResultStruct(date: calendar.date(from: DateComponents(timeZone: TimeZone(abbreviation: "BRT"), year: 2021, month: 2, day: 20))!, exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 4, answeredInterval: 1, result: false),
                        //ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                      //       correctInterval: 5, answeredInterval: 1, result: true),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 6, answeredInterval: 6, result: true),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 7, answeredInterval: 7, result: true),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 8, answeredInterval: 8, result: true),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 9, answeredInterval: 9, result: true),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 10, answeredInterval: 10, result: true),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 11, answeredInterval: 11, result: true),
                        ExerciseResultStruct(date: Date(), exerciseType: ExerciseType.singingExercise.rawValue,
                                             correctInterval: 12, answeredInterval: 12, result: true)
]



