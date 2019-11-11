//
//  ViewController.swift
//  LineGraph
//
//  Created by Sam Lambert on 10/26/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit
import Grapher

class ViewController: UIViewController, StoryboardLoadable {

    @IBOutlet weak var graph: Graph!
    @IBOutlet weak var touchLabel: UILabel!
    @IBOutlet weak var touchLabelLeading: NSLayoutConstraint!
    
    var data = GraphData(xRange: Data.minX...Data.maxX,
                         yRange: Data.minY...Data.maxY)

    override func viewDidLoad() {
        super.viewDidLoad()

        graph.delegate = self
        graph.graph = data

        graph.lines.append(LineData(points: Data.points, primaryColor: .blue, secondaryColor: .purple))

        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.graph.lines.append(LineData(points: Data.points2, primaryColor: .red, secondaryColor: .magenta))
        })
    }

    // for screen size changes like device rotation
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        graph.setNeedsDisplay()
    }
}

extension ViewController: GraphDelegate {
    func didTouch(at points: GraphPoints, position: CGPoint) {
        touchLabel.numberOfLines = points.count

        var text = ""
        for index in 0..<points.count {
            text.append("\(points[index].0), \(points[index].1)")
            if index < points.count - 1 {
                text.append("\n")
            }
        }
        touchLabel.text = text

        let x = position.x
        touchLabelLeading.isActive = false
        touchLabelLeading = touchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                                constant: 25 + x)
        touchLabelLeading.isActive = true
    }

    func didStopTouching() {

        touchLabel.text = nil
        touchLabelLeading.isActive = false
        touchLabelLeading = touchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                                constant: 25)
        touchLabelLeading.isActive = true
    }
}
