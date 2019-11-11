//
//  GraphOverlay.swift
//  Grapher
//
//  Created by Sam Lambert on 10/27/19.
//  Copyright © 2019 Sam Lambert. All rights reserved.
//

import UIKit

internal protocol GraphTouchDelegate: AnyObject {
    func dragged(in rect: CGRect, at point: CGPoint)

    func stoppedDragging()
}

/// Overlaid view to receive touch events for Graph
/// - Prevents redrawing entire graph during drag events
internal class TouchOverlay: UIView {

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
