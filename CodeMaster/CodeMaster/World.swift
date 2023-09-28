//
//  World.swift
//  CodeMaster
//
//  Created by Nevio Hirani on 28.09.23.
//

import Foundation

var currentWorld: World = .init()

struct World {
    var shellClient: ShellClient = .live()
}
