//
//  GraphSize.swift
//  Grapher
//
//  Created by Sam Lambert on 10/27/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit

/// x, y coordinates that compose graph lines
public typealias Point = (x: Double, y: Double)

// internal points using CGFloat
typealias GraphPoint = (x: CGFloat, y: CGFloat)
typealias GraphPoints = [GraphPoint]

/// Size of the graph along x and y axes
public struct GraphSize {

    let minX: CGFloat
    let minY: CGFloat
    let maxX: CGFloat
    let maxY: CGFloat

    public init(xRange: ClosedRange<Double>, yRange: ClosedRange<Double>) {
        minX = CGFloat(xRange.lowerBound)
        maxX = CGFloat(xRange.upperBound)
        minY = CGFloat(yRange.lowerBound)
        maxY = CGFloat(yRange.upperBound)
    }
}

/// Data used to represent a line in a graph
public struct LineData {

    /// The Points that make up the line (should be pre-sorted by x-value)
    public var points: [Point]
    /// The top color for a two-color line or the only color for a single-color line
    let primaryColor: UIColor
    /// The bottom color for a two-color line (nil if only one color)
    let secondaryColor: UIColor?

    /**
     - parameters:
        - points: The Points that make up the line (should be pre-sorted by x-value)
        - primaryColor: The top color for a two-color line or the only color for a single-color line
        - secondaryColor: The bottom color for a two-color line (nil if only one color)
     */
    public init(points: [Point], primaryColor: UIColor, secondaryColor: UIColor? = nil) {
        self.points = points
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
}
