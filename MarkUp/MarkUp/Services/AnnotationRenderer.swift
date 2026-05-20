import UIKit
import CoreImage
import PDFKit
import SwiftUI

struct AnnotationRenderer {
    static func render(annotations: [Annotation], on image: UIImage, scale: CGFloat = 0) -> UIImage {
        let renderScale = scale > 0 ? scale : UIScreen.main.scale
        let imageSize = image.size
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let renderScaleFinal = renderScale

        let result = renderer.image { context in
            image.draw(at: .zero)

            for annotation in annotations {
                let cgContext = context.cgContext
                cgContext.saveGState()
                cgContext.setAlpha(annotation.opacity)

                switch annotation.type {
                case .loupe:
                    drawLoupe(annotation, in: cgContext, scale: renderScaleFinal)
                case .shape:
                    drawShape(annotation, in: cgContext)
                case .arrow:
                    drawArrow(annotation, in: cgContext)
                case .text:
                    drawText(annotation, in: cgContext)
                case .drawing:
                    drawDrawing(annotation, in: cgContext)
                case .highlight:
                    drawHighlight(annotation, in: cgContext)
                case .blur:
                    break
                }

                cgContext.restoreGState()
            }
        }

        return result
    }

    static func renderPDF(annotations: [Annotation], on image: UIImage) -> Data? {
        let pageRect = CGRect(origin: .zero, size: image.size)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            image.draw(at: .zero)

            let cgContext = context.cgContext
            for annotation in annotations {
                cgContext.saveGState()
                cgContext.setAlpha(annotation.opacity)

                switch annotation.type {
                case .loupe:
                    drawLoupe(annotation, in: cgContext, scale: 1)
                case .shape:
                    drawShape(annotation, in: cgContext)
                case .arrow:
                    drawArrow(annotation, in: cgContext)
                case .text:
                    drawText(annotation, in: cgContext)
                case .drawing:
                    drawDrawing(annotation, in: cgContext)
                case .highlight:
                    drawHighlight(annotation, in: cgContext)
                case .blur:
                    break
                }

                cgContext.restoreGState()
            }
        }

        return data
    }

    private static func drawLoupe(_ annotation: Annotation, in context: CGContext, scale: CGFloat) {
        let center = annotation.position
        let radius = annotation.size.width / 2
        let zoomLevel = annotation.zoomLevel ?? 2.0

        context.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: annotation.size.width,
            height: annotation.size.height
        ))
        context.setStrokeColor(UIColor(annotation.color.color).cgColor)
        context.setLineWidth(annotation.lineWidth)
        context.strokePath()

        context.addEllipse(in: CGRect(
            x: center.x - radius + 2,
            y: center.y - radius + 2,
            width: annotation.size.width - 4,
            height: annotation.size.height - 4
        ))
        context.clip()

        context.scaleBy(x: zoomLevel, y: zoomLevel)
        context.translateBy(x: -center.x * (zoomLevel - 1) / zoomLevel,
                           y: -center.y * (zoomLevel - 1) / zoomLevel)
    }

    private static func drawShape(_ annotation: Annotation, in context: CGContext) {
        guard let shapeType = annotation.shapeType else { return }
        let rect = CGRect(origin: annotation.position, size: annotation.size)
        let path = shapePath(shapeType, in: rect)

        context.addPath(path)
        context.setStrokeColor(UIColor(annotation.color.color).cgColor)
        context.setLineWidth(annotation.lineWidth)

        if annotation.isFilled {
            context.setFillColor(UIColor(annotation.color.color).withAlphaComponent(0.3).cgColor)
            context.drawPath(using: .fillStroke)
        } else {
            context.strokePath()
        }
    }

    private static func shapePath(_ shapeType: ShapeType, in rect: CGRect) -> CGPath {
        switch shapeType {
        case .circle:
            return CGPath(ellipseIn: rect, transform: nil)
        case .rectangle:
            return CGPath(rect: rect, transform: nil)
        case .triangle:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        case .star:
            return starPath(in: rect)
        case .chatBubble:
            let path = CGMutablePath()
            let inset: CGFloat = min(rect.width, rect.height) * 0.15
            let bubbleRect = CGRect(x: rect.minX, y: rect.minY,
                                    width: rect.width, height: rect.height - inset)
            path.addRoundedRect(in: bubbleRect, cornerWidth: inset * 0.5, cornerHeight: inset * 0.5)
            path.move(to: CGPoint(x: rect.midX - inset * 0.5, y: bubbleRect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX + inset * 0.5, y: bubbleRect.maxY))
            return path
        }
    }

    private static func starPath(in rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5

        for i in 0..<points * 2 {
            let angle = Double(i) * .pi / Double(points) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    private static func drawArrow(_ annotation: Annotation, in context: CGContext) {
        guard let start = annotation.startPoint,
              let end = annotation.endPoint else { return }

        context.setStrokeColor(UIColor(annotation.color.color).cgColor)
        context.setLineWidth(annotation.lineWidth)
        context.setLineCap(.round)

        context.move(to: start)
        context.addLine(to: end)
        context.strokePath()

        let angle = atan2(end.y - start.y, end.x - start.x)
        let headLength: CGFloat = max(annotation.lineWidth * 4, 12)
        let headAngle: CGFloat = .pi / 6

        context.setFillColor(UIColor(annotation.color.color).cgColor)
        context.move(to: end)
        context.addLine(to: CGPoint(
            x: end.x - headLength * cos(angle - headAngle),
            y: end.y - headLength * sin(angle - headAngle)
        ))
        context.addLine(to: CGPoint(
            x: end.x - headLength * cos(angle + headAngle),
            y: end.y - headLength * sin(angle + headAngle)
        ))
        context.closePath()
        context.fillPath()
    }

    private static func drawText(_ annotation: Annotation, in context: CGContext) {
        guard let text = annotation.text, !text.isEmpty else { return }
        let fontSize = annotation.fontSize ?? 16
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(annotation.color.color)
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        attributedString.draw(at: annotation.position)
    }

    private static func drawDrawing(_ annotation: Annotation, in context: CGContext) {
        guard let points = annotation.pathPoints, points.count > 1 else { return }

        context.setStrokeColor(UIColor(annotation.color.color).cgColor)
        context.setLineWidth(annotation.lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        context.move(to: CGPoint(x: points[0].x, y: points[0].y))
        for i in 1..<points.count {
            context.addLine(to: CGPoint(x: points[i].x, y: points[i].y))
        }
        context.strokePath()
    }

    private static func drawHighlight(_ annotation: Annotation, in context: CGContext) {
        guard let points = annotation.pathPoints, points.count > 1 else { return }

        context.setStrokeColor(UIColor(annotation.color.color).cgColor)
        context.setLineWidth(annotation.lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setBlendMode(.multiply)

        context.move(to: CGPoint(x: points[0].x, y: points[0].y))
        for i in 1..<points.count {
            context.addLine(to: CGPoint(x: points[i].x, y: points[i].y))
        }
        context.strokePath()
    }
}
