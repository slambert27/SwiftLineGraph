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



/**
 Main graph view
 - Parameters:
    - view: the superview to which this view will be added
    - width: the desired width of this view
    - height: the desired height of this view
 - Note: view will add itself to superview and constrain width and height
 */
class Graph: UIView {

    let width: CGFloat
    let height: CGFloat

    let graph: GraphData

    var lines: [LineData] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    var tapPoint: CGFloat?

    init(in view: UIView, width: CGFloat, height: CGFloat, graph: GraphData) {
        self.width = width
        self.height = height
        self.graph = graph
        super.init(frame: .zero)

        constrain(view: view)

        backgroundColor = .white

        let panRecognizer = GraphDragGesture(target: self, action: #selector(didTapGraph))
        addGestureRecognizer(panRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func constrain(view: UIView) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }

    override func draw(_ rect: CGRect) {

        // data height in each axis
        let dataHeight = graph.maxY - graph.minY
        let dataWidth = graph.maxX - graph.minX

        // data to screen scale ex. 5 means 5 screen pixels for each data point
        let scaleY = height / dataHeight
        let scaleX = width / dataWidth

        // screen point where y = 0
        let zeroY: CGFloat = graph.maxY * scaleY

        drawHPath(at: zeroY)
        drawHPath(at: 0 + 0.5)
        drawHPath(at: height - 0.5)

        for line in lines {
            let points = line.points.sorted(by: { $0.0 < $1.0 })

            let path = UIBezierPath()
            // x-value - account for scale between data and screen size
            // y value - account for dynamic 0-point, inverted coordinates and scale
            path.move(to: CGPoint(x: points[0].0 * scaleX, y: zeroY - (points[0].1 * scaleY)))

            for index in 1..<points.count {
                path.addLine(to: CGPoint(x: points[index].0 * scaleX, y: zeroY - (points[index].1 * scaleY)))
            }
            line.color.set()
            path.stroke()
        }

        if let tap = tapPoint {
            drawVPath(at: tap)
        }
    }

    private func drawHPath(at yValue: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: yValue))
        path.addLine(to: CGPoint(x: width, y: yValue))
        UIColor.lightGray.set()
        path.setLineDash([2, 2], count: 2, phase: 0)
        path.stroke()
    }

    private func drawVPath(at xValue: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xValue, y: 0))
        path.addLine(to: CGPoint(x: xValue, y: height))
        UIColor.black.set()
        path.stroke()
    }

    @objc
    private func didTapGraph(_ gesture: UITapGestureRecognizer) {

        let point = gesture.location(in: self)

        if gesture.state == .ended {
            tapPoint = nil
            setNeedsDisplay()
        } else {
            tapPoint = point.x
            setNeedsDisplay()
        }
    }
}

class GraphDragGesture: UIPanGestureRecognizer {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
    }
}
