//
//  ViewController.swift
//  LineGraph
//
//  Created by Sam Lambert on 10/26/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var data = GraphData(minX: CGFloat(Data.minX),
                         minY: CGFloat(Data.minY),
                         maxX: CGFloat(Data.maxX),
                         maxY: CGFloat(Data.maxY))

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let graph = Graph(in: view, width: UIScreen.main.bounds.width - 50, height: 200, graph: data)

        NSLayoutConstraint.activate([
            graph.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            graph.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        graph.lines.append(LineData(points: Data.points, color: .blue))

        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            graph.lines.append(LineData(points: Data.points2, color: .red))
        })
    }
}
