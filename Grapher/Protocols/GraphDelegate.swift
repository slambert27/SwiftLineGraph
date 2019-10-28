//
//  GraphDelegate.swift
//  Grapher
//
//  Created by Sam Lambert on 10/27/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import Foundation

public protocol GraphDelegate: AnyObject {

    /// after a touch or drag event by user, returns the dataPoint nearest to the touch for each line in graph
    func didTouch(at points: GraphPoints)

    /// user has is no longer interacting with graph
    func didStopTouching()
}

extension GraphDelegate {

    func didTouch(at points: GraphPoints) {}

    func didStopTouching() {}
}
