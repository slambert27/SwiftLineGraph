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

    @IBOutlet weak var graph2: Graph!
    @IBOutlet weak var touchLabel2: UILabel!
    
    var data = GraphData(xRange: Data.rangeX, yRange: Data.rangeY)

    override func viewDidLoad() {
        super.viewDidLoad()

        // graph 2 - 2 lines, tap to add second
        graph2.enableDragging = false
        graph2.dividerColor = .clear
        graph2.graph = data
        graph2.lines.append(LineData(points: Data.points, primaryColor: .black))

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapGraph2))
        graph2.addGestureRecognizer(gesture)

        // graph 1 - 1 line, 2 colors, delegate for touch interaction, updating points
        graph.delegate = self
        graph.graph = data

        graph.lines.append(LineData(points: Data.points2, primaryColor: .blue, secondaryColor: .red))

        var count = Data.points2[Data.points2.count - 1].0
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            count += 1

            self.graph.lines[0].points.append((CGFloat(count), CGFloat((-10...10).randomElement() ?? 0)))

            if count == 60 {
                timer.invalidate()
            }
        }
    }

    // for screen size changes like device rotation
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        graph.setNeedsDisplay()
        graph2.setNeedsDisplay()
    }

    @objc
    func didTapGraph2() {
        graph2.lines.append(LineData(points: Data.points2, primaryColor: .green))
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
