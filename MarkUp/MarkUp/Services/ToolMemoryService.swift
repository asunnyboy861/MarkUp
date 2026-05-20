import Foundation
import SwiftUI
import Combine

struct ToolSettings: Codable {
    var lastTool: String
    var lastColor: CodableColor
    var lastLineWidth: CGFloat
    var lastOpacity: Double
    var lastShapeType: ShapeType
    var lastBlurType: BlurType
    var lastDrawingTool: DrawingTool

    static let `default` = ToolSettings(
        lastTool: ToolType.pen.rawValue,
        lastColor: .red,
        lastLineWidth: 2,
        lastOpacity: 1.0,
        lastShapeType: .circle,
        lastBlurType: .gaussian,
        lastDrawingTool: .pen
    )
}

@MainActor
class ToolMemoryService: ObservableObject {
    @Published var settings: ToolSettings

    private let defaults = UserDefaults.standard
    private let settingsKey = "com.zzoutuo.MarkUp.toolSettings"

    init() {
        if let data = defaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(ToolSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .default
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: settingsKey)
        }
    }

    func updateTool(_ tool: ToolType) {
        settings.lastTool = tool.rawValue
        save()
    }

    func updateColor(_ color: CodableColor) {
        settings.lastColor = color
        save()
    }

    func updateLineWidth(_ width: CGFloat) {
        settings.lastLineWidth = width
        save()
    }

    func updateOpacity(_ opacity: Double) {
        settings.lastOpacity = opacity
        save()
    }

    func updateShapeType(_ shapeType: ShapeType) {
        settings.lastShapeType = shapeType
        save()
    }

    func updateBlurType(_ blurType: BlurType) {
        settings.lastBlurType = blurType
        save()
    }

    func updateDrawingTool(_ drawingTool: DrawingTool) {
        settings.lastDrawingTool = drawingTool
        save()
    }

    var currentTool: ToolType {
        ToolType(rawValue: settings.lastTool) ?? .pen
    }
}
