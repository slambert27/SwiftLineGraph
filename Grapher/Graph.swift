//
//  Graph.swift
//  LineGraph
//
//  Created by Sam Lambert on 10/27/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit

/// Graph that can be added
@IBDesignable
public class Graph: UIView {

    // MARK: - public style settings

    /// A Boolean value indicating whether drag gesture interaction is enabled to view values over time
    @IBInspectable
    public var enableDragging: Bool = true {
        didSet {
            if enableDragging {
                setupTouch()
            } else {
                overlay?.removeFromSuperview()
                overlay = nil
            }
        }
    }

    /// Color applied to the horizontal divider lines, set to .clear to hide
    @IBInspectable
    public var dividerColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - public data settings

    public weak var delegate: GraphDelegate?

    public var graph: GraphSize?

    public var lines: [LineData] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - private components

    private var overlay: TouchOverlay?

    // keep track of mask layers, remove on draw to avoid piling them up
    private var currentLayers: [CALayer] = []

    // for storyboard display
    private let points: [Point] = [(0, -10), (2, -17), (3, -14), (5, -15), (6, -14), (8, -16), (9, -9),
                                   (10, -11), (11, -10), (13, -8), (14, -7), (16, -15), (17, -11),
                                   (19, -8), (20, 8), (21, -5), (23, 1), (24, -1), (26, -3), (27, -2)]

    // MARK: - init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupTouch()
    }

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

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        graph = GraphSize(xRange: 0...60, yRange: -50...50)
        lines = [LineData(points: points, primaryColor: .black)]
    }

    // MARK: - private methods

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

    private func drawDivider(in rect: CGRect, at yValue: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: yValue))
        path.addLine(to: CGPoint(x: rect.width, y: yValue))
        dividerColor.set()
        path.setLineDash([2, 2], count: 2, phase: 0)
        path.stroke()
    }

    // MARK: - public methods

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
        drawDivider(in: rect, at: zeroY)
        // +/- 0.5 to keep line width inside view
        drawDivider(in: rect, at: 0 + 0.5)
        drawDivider(in: rect, at: rect.height - 0.5)

        // manage layer count
        currentLayers.forEach { $0.removeFromSuperlayer() }
        currentLayers.removeAll()

        // draw each line
        // line is the full plot for a single data set
        for line in lines {

            let points: GraphPoints = line.points.map { (CGFloat($0.x), CGFloat($0.y)) }

            let path = UIBezierPath()
            // x-value - account for scale between data and screen size
            // y value - account for dynamic 0-point, inverted coordinates and scale
            path.move(to: CGPoint(x: points[0].x * scaleX, y: zeroY - (points[0].y * scaleY)))
            for index in 1..<points.count {
                path.addLine(to: CGPoint(x: points[index].x * scaleX, y: zeroY - (points[index].y * scaleY)))
            }

            // mask used to color line
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            mask.fillColor = nil
            mask.strokeColor = line.primaryColor.cgColor
            mask.lineWidth = 2

            currentLayers.append(mask)
            self.layer.addSublayer(mask)

            // mask used to color top portion of line, covers top area of graph down to y = 0
            if let color = line.secondaryColor?.cgColor {
                let halfMask = CAShapeLayer()
                halfMask.frame = CGRect(x: 0, y: 0, width: rect.width, height: zeroY)
                halfMask.masksToBounds = true
                halfMask.path = path.cgPath

                halfMask.fillColor = nil
                halfMask.strokeColor = color
                halfMask.lineWidth = 2

                currentLayers.append(halfMask)
                self.layer.addSublayer(halfMask)
            }
        }
    }

    /// Set color of the draggable tracking line
    public func setTrackerColor(_ color: UIColor) {
        overlay?.lineColor = color
    }
}

// MARK: - GraphTouchDelegate

extension Graph: GraphTouchDelegate {
    
    func dragged(in rect: CGRect, at point: CGPoint) {

        guard let graph = graph else { return }

        let dataWidth = graph.maxX - graph.minX
        let scaleX = rect.width / dataWidth

        let x = point.x

        let dataX = Double(x / scaleX)

        var points: [Point] = []

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
