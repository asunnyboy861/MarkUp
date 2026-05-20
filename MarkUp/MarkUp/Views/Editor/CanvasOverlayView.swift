import SwiftUI

struct CanvasOverlayView: View {
    @ObservedObject var viewModel: EditorViewModel
    let imageSize: CGSize
    @State private var dragStart: CGPoint?
    @State private var currentPoint: CGPoint?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(viewModel.currentDrawingAnnotations()) { annotation in
                    AnnotationView(annotation: annotation, imageSize: imageSize, viewSize: geometry.size)
                }

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if dragStart == nil {
                                    dragStart = value.startLocation
                                    viewModel.handleDragStart(at: value.startLocation, imageSize: imageSize, viewSize: geometry.size)
                                }
                                viewModel.handleDragMove(at: value.location, imageSize: imageSize, viewSize: geometry.size)
                            }
                            .onEnded { _ in
                                dragStart = nil
                                viewModel.handleDragEnd()
                            }
                    )
            }
        }
    }
}

struct AnnotationView: View {
    let annotation: Annotation
    let imageSize: CGSize
    let viewSize: CGSize

    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / imageSize.width
            let scaledPosition = CGPoint(
                x: annotation.position.x * scale,
                y: annotation.position.y * scale
            )
            let scaledSize = CGSize(
                width: annotation.size.width * scale,
                height: annotation.size.height * scale
            )

            ZStack {
                switch annotation.type {
                case .loupe:
                    LoupeView(annotation: annotation, scale: scale)
                case .shape:
                    ShapeAnnotationView(annotation: annotation, scale: scale)
                case .arrow:
                    ArrowAnnotationView(annotation: annotation, scale: scale)
                case .text:
                    TextAnnotationView(annotation: annotation, scale: scale)
                case .drawing:
                    DrawingAnnotationView(annotation: annotation, scale: scale)
                case .highlight:
                    HighlightAnnotationView(annotation: annotation, scale: scale)
                case .blur:
                    BlurAnnotationView(annotation: annotation, scale: scale)
                }
            }
            .position(x: scaledPosition.x, y: scaledPosition.y)
        }
    }
}

struct LoupeView: View {
    let annotation: Annotation
    let scale: CGFloat

    var body: some View {
        let scaledSize = CGSize(
            width: annotation.size.width * scale,
            height: annotation.size.height * scale
        )
        Circle()
            .stroke(annotation.color.color, lineWidth: annotation.lineWidth * scale)
            .frame(width: scaledSize.width, height: scaledSize.height)
            .overlay(
                Circle()
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: min(scaledSize.width, scaledSize.height) * 0.3))
                    .foregroundStyle(annotation.color.color.opacity(0.5))
            )
    }
}

struct ShapeAnnotationView: View {
    let annotation: Annotation
    let scale: CGFloat

    var body: some View {
        let scaledSize = CGSize(
            width: annotation.size.width * scale,
            height: annotation.size.height * scale
        )
        Group {
            switch annotation.shapeType {
            case .circle:
                if annotation.isFilled {
                    Circle()
                        .fill(annotation.color.color.opacity(0.3))
                        .frame(width: scaledSize.width, height: scaledSize.height)
                        .overlay(
                            Circle()
                                .stroke(annotation.color.color, lineWidth: annotation.lineWidth * scale)
                        )
                } else {
                    Circle()
                        .stroke(annotation.color.color, lineWidth: annotation.lineWidth * scale)
                        .frame(width: scaledSize.width, height: scaledSize.height)
                }
            case .rectangle:
                if annotation.isFilled {
                    Rectangle()
                        .fill(annotation.color.color.opacity(0.3))
                        .frame(width: scaledSize.width, height: scaledSize.height)
                        .overlay(
                            Rectangle()
                                .stroke(annotation.color.color, lineWidth: annotation.lineWidth * scale)
                        )
                } else {
                    Rectangle()
                        .stroke(annotation.color.color, lineWidth: annotation.lineWidth * scale)
                        .frame(width: scaledSize.width, height: scaledSize.height)
                }
            case .triangle:
                TriangleShape()
                    .stroke(annotation.color.color, lineWidth: annotation.lineWidth * scale)
                    .frame(width: scaledSize.width, height: scaledSize.height)
            case .star:
                StarShape()
                    .stroke(annotation.color.color, lineWidth: annotation.lineWidth * scale)
                    .frame(width: scaledSize.width, height: scaledSize.height)
            case .chatBubble:
                ChatBubbleShape()
                    .stroke(annotation.color.color, lineWidth: annotation.lineWidth * scale)
                    .frame(width: scaledSize.width, height: scaledSize.height)
            case .none:
                EmptyView()
            }
        }
    }
}

struct ArrowAnnotationView: View {
    let annotation: Annotation
    let scale: CGFloat

    var body: some View {
        if let start = annotation.startPoint, let end = annotation.endPoint {
            ArrowShape(
                start: CGPoint(x: start.x * scale, y: start.y * scale),
                end: CGPoint(x: end.x * scale, y: end.y * scale),
                lineWidth: annotation.lineWidth * scale
            )
            .stroke(annotation.color.color, style: StrokeStyle(
                lineWidth: annotation.lineWidth * scale,
                lineCap: .round
            ))
        }
    }
}

struct TextAnnotationView: View {
    let annotation: Annotation
    let scale: CGFloat

    var body: some View {
        if let text = annotation.text {
            Text(text)
                .font(.system(size: (annotation.fontSize ?? 18) * scale))
                .foregroundStyle(annotation.color.color)
        }
    }
}

struct DrawingAnnotationView: View {
    let annotation: Annotation
    let scale: CGFloat

    var body: some View {
        if let points = annotation.pathPoints, points.count > 1 {
            Path { path in
                let first = points[0]
                path.move(to: CGPoint(x: first.x * scale, y: first.y * scale))
                for point in points.dropFirst() {
                    path.addLine(to: CGPoint(x: point.x * scale, y: point.y * scale))
                }
            }
            .stroke(annotation.color.color, style: StrokeStyle(
                lineWidth: annotation.lineWidth * scale,
                lineCap: .round,
                lineJoin: .round
            ))
        }
    }
}

struct HighlightAnnotationView: View {
    let annotation: Annotation
    let scale: CGFloat

    var body: some View {
        if let points = annotation.pathPoints, points.count > 1 {
            Path { path in
                let first = points[0]
                path.move(to: CGPoint(x: first.x * scale, y: first.y * scale))
                for point in points.dropFirst() {
                    path.addLine(to: CGPoint(x: point.x * scale, y: point.y * scale))
                }
            }
            .stroke(annotation.color.color.opacity(annotation.opacity), style: StrokeStyle(
                lineWidth: annotation.lineWidth * scale,
                lineCap: .round,
                lineJoin: .round
            ))
            .blendMode(.multiply)
        }
    }
}

struct BlurAnnotationView: View {
    let annotation: Annotation
    let scale: CGFloat

    var body: some View {
        let scaledSize = CGSize(
            width: annotation.size.width * scale,
            height: annotation.size.height * scale
        )
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.white.opacity(0.3))
            .frame(width: scaledSize.width, height: scaledSize.height)
            .overlay(
                Image(systemName: annotation.blurType == .pixelate ? "grid" : "drop")
                    .foregroundStyle(.gray.opacity(0.5))
            )
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> SwiftUI.Path {
        var path = SwiftUI.Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> SwiftUI.Path {
        var path = SwiftUI.Path()
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
}

struct ChatBubbleShape: Shape {
    func path(in rect: CGRect) -> SwiftUI.Path {
        var path = SwiftUI.Path()
        let inset = min(rect.width, rect.height) * 0.15
        let bubbleRect = CGRect(x: rect.minX, y: rect.minY,
                                width: rect.width, height: rect.height - inset)
        path.addRoundedRect(in: bubbleRect, cornerSize: CGSize(width: inset * 0.5, height: inset * 0.5))
        path.move(to: CGPoint(x: rect.midX - inset * 0.5, y: bubbleRect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX + inset * 0.5, y: bubbleRect.maxY))
        return path
    }
}

struct ArrowShape: Shape {
    let start: CGPoint
    let end: CGPoint
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> SwiftUI.Path {
        var path = SwiftUI.Path()
        path.move(to: start)
        path.addLine(to: end)

        let angle = atan2(end.y - start.y, end.x - start.x)
        let headLength = max(lineWidth * 4, 12)
        let headAngle = CGFloat.pi / 6

        path.move(to: end)
        path.addLine(to: CGPoint(
            x: end.x - headLength * cos(angle - headAngle),
            y: end.y - headLength * sin(angle - headAngle)
        ))
        path.move(to: end)
        path.addLine(to: CGPoint(
            x: end.x - headLength * cos(angle + headAngle),
            y: end.y - headLength * sin(angle + headAngle)
        ))

        return path
    }
}
