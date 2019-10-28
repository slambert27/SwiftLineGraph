//
//  GraphData.swift
//  Grapher
//
//  Created by Sam Lambert on 10/27/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit

public typealias GraphPoints = [(CGFloat, CGFloat)]

public struct GraphData {

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

public struct LineData {

    var points: GraphPoints
    let color: UIColor

    public init(points: GraphPoints, color: UIColor) {
        self.points = points
        self.color = color
    }
}
