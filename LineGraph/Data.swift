//
//  Data.swift
//  LineGraph
//
//  Created by Sam Lambert on 10/26/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit

typealias GraphPoints = [(CGFloat, CGFloat)]

struct GraphData {

    let minX: CGFloat
    let minY: CGFloat
    let maxX: CGFloat
    let maxY: CGFloat
}

struct LineData {

    var points: GraphPoints
    let color: UIColor
}

enum Data {

    static let points: GraphPoints = [(0, -10), (2, -17), (3, -14), (5, -15), (6, -14), (8, -16), (9, -9),
                                      (10, -11), (11, -10), (13, -8), (14, -7), (16, -15), (17, -11),
                                      (19, -8), (20, 8), (21, -5), (23, 1), (24, -1), (26, -3), (27, -2)]

    static let points2: GraphPoints = [(0, 20), (2, 21), (3, 10), (5, 11), (6, 15), (8, 2), (9, 0),
                                      (10, 4), (11, -5), (13, -6), (14, -3), (16, -9), (17, -12),
                                      (19, -10), (20, -11), (21, -1), (23, 2), (24, -3), (26, 4), (27, 8)]

    static let minX = 0.0

    static let maxX = 60.0

    static let minY = -50.0

    static let maxY = 50.0
}
