//
//  ExerciseResultExtension.swift
//  Cantar intervalo
//
//  Created by Macintosh on 21/02/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import Foundation

extension ExerciseResult {
    var exerciseType: ExerciseType {
        get {
            return ExerciseType(rawValue: self.exerciseTypeValue)
        }
        set {
            self.exerciseType =
        }
    }
    
}
