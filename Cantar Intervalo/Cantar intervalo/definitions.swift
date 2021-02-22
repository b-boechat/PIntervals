//
//  definitions.swift
//  Cantar intervalo
//
//  Created by Macintosh on 30/01/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import Foundation

// Array of strings containing interval names.
let intervalsArray : [String] = ["Segunda menor",
                                "Segunda maior",
                                "Terça menor",
                                "Terça maior",
                                "Quarta justa",
                                "Quarta aumentada",
                                "Quinta justa",
                                "Sexta menor",
                                "Sexta maior",
                                "Sétima menor",
                                "Sétima maior",]

// Array of note filenames. Notes range from A2 (MIDI 45) to G#4 (MIDI 68)
let notesArray : [String] = ["45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56",
                             "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68"]

// First note (A2) Pitchy index.
let firstNotePitchyIndex : Int = -24

// Exercise types. Raw value of Int16, so they can be saved with Core Data.
enum ExerciseType : Int16 {
    case singingExercise = 0
    case identificationExercise = 1
}

// Constant used for Core Data storage for the singing exercise.
let NO_NOTE_MAINTAINED: Int16 = -1
