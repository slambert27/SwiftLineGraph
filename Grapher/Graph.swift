//
//  Graph.swift
//  LineGraph
//
//  Created by Sam Lambert on 10/27/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit

/// Graph that can be added
public class Graph: UIView {

    // MARK: - public style settings

    /// A Boolean indicating whether to display horizontal lines at key y-values
    public var showDividerLines = true

    /// A Boolean value indicating whether drag gesture interaction is enabled to view values over time
    public var enableDragging = true {
        didSet {
            if enableDragging {
                setupTouch()
            } else {
                overlay?.removeFromSuperview()
                overlay = nil
            }
        }
    }

    // MARK: - public data settings

    public weak var delegate: GraphDelegate?

    public var graph: GraphData?

    public var lines: [LineData] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    private var overlay: TouchOverlay?

    public init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        setupTouch()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        setupTouch()
    }

    private func setupTouch() {
        overlay = TouchOverlay()
        guard let overlay = overlay else { return }

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

    private func drawHPath(in rect: CGRect, at yValue: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: yValue))
        path.addLine(to: CGPoint(x: rect.width, y: yValue))
        UIColor.lightGray.set()
        path.setLineDash([2, 2], count: 2, phase: 0)
        path.stroke()
    }

    override public func draw(_ rect: CGRect) {

        guard let graph = graph else { return }

        // data height in each axis
        let dataHeight = graph.maxY - graph.minY
        let dataWidth = graph.maxX - graph.minX

        // data to screen scale ex. 5 means 5 screen pixels for each data point
        let scaleY = rect.height / dataHeight
        let scaleX = rect.width / dataWidth

        // screen point at which y = 0
        let zeroY: CGFloat = graph.maxY * scaleY

        // draw horizontal lines at min and max y values and 0 y value
        if showDividerLines {
            drawHPath(in: rect, at: zeroY)
            drawHPath(in: rect, at: 0 + 0.5)
            drawHPath(in: rect, at: rect.height - 0.5)
        }

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

            let halfMask = CAShapeLayer()
            halfMask.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height / 2)
            halfMask.masksToBounds = true
            halfMask.path = path.cgPath

            halfMask.fillColor = nil
            halfMask.strokeColor = line.secondaryColor?.cgColor ?? line.primaryColor.cgColor
            halfMask.lineWidth = 2

            let mask = CAShapeLayer()
            mask.path = path.cgPath

            mask.fillColor = nil
            mask.strokeColor = line.primaryColor.cgColor
            mask.lineWidth = 2

            self.layer.insertSublayer(mask, at: 0)
            self.layer.insertSublayer(halfMask, at: 1)
        }
    }
}

extension Graph: GraphTouchDelegate {
    func dragged(in rect: CGRect, at point: CGPoint) {

        guard let graph = graph else { return }

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

        delegate?.didTouch(at: points, position: point)
    }

    func stoppedDragging() {
        delegate?.didStopTouching()
    }
}
