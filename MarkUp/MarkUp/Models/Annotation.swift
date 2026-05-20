import SwiftUI
import Foundation

enum AnnotationType: String, Codable, CaseIterable {
    case loupe
    case shape
    case arrow
    case text
    case drawing
    case highlight
    case blur
}

enum ShapeType: String, Codable, CaseIterable {
    case circle
    case rectangle
    case triangle
    case star
    case chatBubble
}

enum BlurType: String, Codable {
    case gaussian
    case pixelate
}

enum DrawingTool: String, Codable, CaseIterable {
    case pen
    case marker
    case pencil
}

struct CodableColor: Codable, Equatable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }

    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    static let red = CodableColor(red: 1, green: 0, blue: 0)
    static let orange = CodableColor(red: 1, green: 0.584, blue: 0)
    static let yellow = CodableColor(red: 1, green: 0.922, blue: 0)
    static let green = CodableColor(red: 0, green: 0.784, blue: 0.314)
    static let blue = CodableColor(red: 0, green: 0.478, blue: 1)
    static let purple = CodableColor(red: 0.545, green: 0, blue: 1)
    static let black = CodableColor(red: 0, green: 0, blue: 0)
    static let white = CodableColor(red: 1, green: 1, blue: 1)

    static let presetColors: [CodableColor] = [.red, .orange, .yellow, .green, .blue, .purple, .black, .white]
}

struct Annotation: Identifiable, Codable {
    let id: UUID
    let type: AnnotationType
    var position: CGPoint
    var size: CGSize
    var color: CodableColor
    var lineWidth: CGFloat
    var opacity: Double
    var isFilled: Bool
    var text: String?
    var fontSize: CGFloat?
    var pathPoints: [PathPoint]?
    var zoomLevel: CGFloat?
    var blurIntensity: CGFloat?
    var blurType: BlurType?
    var shapeType: ShapeType?
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var drawingTool: DrawingTool?

    init(type: AnnotationType,
         position: CGPoint = .zero,
         size: CGSize = .zero,
         color: CodableColor = .red,
         lineWidth: CGFloat = 2,
         opacity: Double = 1.0,
         isFilled: Bool = false) {
        self.id = UUID()
        self.type = type
        self.position = position
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
        self.opacity = opacity
        self.isFilled = isFilled
    }
}

struct PathPoint: Codable {
    let x: CGFloat
    let y: CGFloat
    let force: CGFloat?

    init(x: CGFloat, y: CGFloat, force: CGFloat? = nil) {
        self.x = x
        self.y = y
        self.force = force
    }
}
