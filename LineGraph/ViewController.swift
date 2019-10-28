//
//  ViewController.swift
//  LineGraph
//
//  Created by Sam Lambert on 10/26/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit
import Grapher

class ViewController: UIViewController {

    let touchLabel = UILabel()

    var data = GraphData(xRange: Data.minX...Data.maxX,
                         yRange: Data.minY...Data.maxY)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let graph = Graph(graph: data)
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.delegate = self

        view.addSubview(graph)
        view.addSubview(touchLabel)
        touchLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            graph.heightAnchor.constraint(equalToConstant: 200),
            graph.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 50),
            graph.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            graph.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            touchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            touchLabel.bottomAnchor.constraint(equalTo: graph.topAnchor, constant: -15)
        ])

        graph.lines.append(LineData(points: Data.points, color: .blue))

        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            graph.lines.append(LineData(points: Data.points2, color: .red))
        })
    }
}

extension ViewController: GraphDelegate {
    func didTouch(at points: GraphPoints) {
        touchLabel.numberOfLines = points.count

        var text = ""
        for index in 0..<points.count {
            text.append("\(points[index].0), \(points[index].1)")
            if index < points.count - 1 {
                text.append("\n")
            }
        }
        touchLabel.text = text
    }

    func didStopTouching() {
        touchLabel.text = nil
    }
}
