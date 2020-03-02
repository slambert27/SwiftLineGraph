//
//  GraphDelegate.swift
//  Grapher
//
//  Created by Sam Lambert on 10/27/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit

/// Delegate that receives user events from a Graph
public protocol GraphDelegate: AnyObject {

    /// called after a touch or drag event by user
    /// - parameters:
    ///     - points: array containing the dataPoint nearest to the touch for each line in graph
    ///     - position: screen position of the touch
    func didTouch(at points: [Point], position: CGPoint)

    /// User is no longer interacting with graph
    func didStopTouching()
}

// provide empty defaults to make implementations optional
public extension GraphDelegate {

    func didTouch(at points: [Point], position: CGPoint) {}

    func didStopTouching() {}
}
