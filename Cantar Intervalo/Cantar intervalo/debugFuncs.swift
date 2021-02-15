//
//  debugFuncs.swift
//  processando-audio
//
//  Created by Macintosh on 28/01/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import Foundation

extension ViewController {
    
    func checkBufferDuration() {
        let bufferDuration = audioInput.audioSession.ioBufferDuration
        debugLabel.text = "\(bufferDuration)"
    }
    
}
