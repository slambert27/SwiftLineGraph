//
//  Graph.swift
//  LineGraph
//
//  Created by Sam Lambert on 10/27/19.
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

protocol GraphTouchDelegate: AnyObject {
    func dragged(in rect: CGRect, at point: CGPoint)

    func stoppedDragging()
}

protocol GraphDelegate: AnyObject {

    /// after a touch or drag event by user, returns the dataPoint nearest to the touch for each line in graph
    func didTouch(at points: GraphPoints)

    /// user has is no longer interacting with graph
    func didStopTouching()
}

extension GraphDelegate {

    func didTouch(at points: GraphPoints) {}

    func didStopTouching() {}
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

    weak var delegate: GraphDelegate?

    private let graph: GraphData

    var lines: [LineData] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    init(graph: GraphData) {
        self.graph = graph
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        backgroundColor = .clear

        let overlay = TouchOverlay()
        overlay.delegate = self

        addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func draw(_ rect: CGRect) {

        // data height in each axis
        let dataHeight = graph.maxY - graph.minY
        let dataWidth = graph.maxX - graph.minX

        // data to screen scale ex. 5 means 5 screen pixels for each data point
        let scaleY = rect.height / dataHeight
        let scaleX = rect.width / dataWidth

        // screen point at which y = 0
        let zeroY: CGFloat = graph.maxY * scaleY

        // draw horizontal lines at min and max y values and 0 y value
        drawHPath(in: rect, at: zeroY)
        drawHPath(in: rect, at: 0 + 0.5)
        drawHPath(in: rect, at: rect.height - 0.5)

        // draw each line
        // line is the full plot for a single data set
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
            path.lineWidth = 2
            path.stroke()
        }
    }

    private func drawHPath(in rect: CGRect, at yValue: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: yValue))
        path.addLine(to: CGPoint(x: rect.width, y: yValue))
        UIColor.lightGray.set()
        path.setLineDash([2, 2], count: 2, phase: 0)
        path.stroke()
    }
}

extension Graph: GraphTouchDelegate {
    func dragged(in rect: CGRect, at point: CGPoint) {

        let dataWidth = graph.maxX - graph.minX
        let scaleX = rect.width / dataWidth

        let x = point.x

        let dataX = x / scaleX

        var points: GraphPoints = []

        for line in lines {
            let closestDataPoint = line.points.min { abs($0.0 - dataX) < abs($1.0 - dataX) }

            if let point = closestDataPoint {
                points.append(point)
            }
        }

        delegate?.didTouch(at: points)
    }

    func stoppedDragging() {
        delegate?.didStopTouching()
    }
}

/// Overlaid view to receive touch events for Graph
/// - Note: Prevents redrawing entire graph during drag events
class TouchOverlay: UIView {

    weak var delegate: GraphTouchDelegate?

    // position of vertical draggable line, no line if nil
    var tapPoint: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear

        let panRecognizer = GraphDragGesture(target: self, action: #selector(didTapGraph))
        addGestureRecognizer(panRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func didTapGraph(_ gesture: UITapGestureRecognizer) {

        let point = gesture.location(in: self)

        if gesture.state == .ended {
            tapPoint = nil
            delegate?.stoppedDragging()
        } else {
            tapPoint = point
        }
    }

    override func draw(_ rect: CGRect) {
        if let tap = tapPoint {
            drawVPath(in: rect, at: tap.x)
            delegate?.dragged(in: rect, at: tap)
        }
    }

    private func drawVPath(in rect: CGRect, at xValue: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xValue, y: 0))
        path.addLine(to: CGPoint(x: xValue, y: rect.height))
        UIColor.gray.set()
        path.stroke()
    }
}

/// Custom pan gesture to ensure event begins on inital touch
class GraphDragGesture: UIPanGestureRecognizer {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
    }
}
