//
//  utilities.swift
//  Cantar intervalo
//
//  Created by Macintosh on 21/02/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import Foundation


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

func getInterval(target: Int, reference: Int) -> Int16 {
    // Returns semitone interval between two notes, modulo 12 (an octave). Always returns the first positive interval
    // Note that "segunda menor" is mapped to 1, so all intervals are one integer higher than their corresponding arrayIndex.
    let rem = Int16((target - reference) % 12)
    return rem > 0 ? rem : rem + 12
}
