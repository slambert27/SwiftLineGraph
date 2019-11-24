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

        // setup graph 1 from json data
        guard let url = Bundle.main.url(forResource: "odds", withExtension: "json") else { return }
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let data = data,
                let model = try? JSONDecoder().decode(JsonData.self, from: data) {

                let lineData = self.convertLineData(from: model)
                DispatchQueue.main.async {
                    self.graph.lines.append(lineData)
                    self.startAdding()
                }
            }
        }
        task.resume()
    }

    func startAdding() {
        // graph 1 random updating to fill to end
        var count = graph.lines[0].points.last?.0 ?? 0
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            count += 0.5
            let last = Int(self.graph.lines[0].points.last?.1 ?? 0)
            self.graph.lines[0].points.append((count, Double(((last - 1)...(last + 1)).randomElement() ?? 0)))

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

    private func convertLineData(from model: JsonData) -> LineData {
        var points: [Point] = []
        for object in model.data {
            if object.team == "top" {
                let point = (object.time, object.odds - 50)
                points.append(point)
            } else {
                let point = (object.time, -object.odds + 50)
                points.append(point)
            }
        }

        return LineData(points: points, primaryColor: .blue, secondaryColor: .red)
    }
}

extension ViewController: GraphDelegate {
    func didTouch(at points: [Point], position: CGPoint) {
        touchLabel.numberOfLines = points.count

        var text = ""
        for index in 0..<points.count {
            let value = points[index]

            // time
            let totalSeconds = value.x * 60

            let minute = Int(totalSeconds / 60)
            let second = Int(totalSeconds.truncatingRemainder(dividingBy: 60).rounded())

            let time = "\(minute):\(String(format: "%02d", second))"

            // odds
            let odds: Double
            let team: String

            if value.y < 0 {
                odds = -value.y + 50
                team = "BOT"
            } else if value.y == 0 {
                odds = 50
                team = "EVEN"
            } else {
                odds = value.y + 50
                team = "TOP"
            }

            text.append("\(time), \(team): \(odds)%")
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
