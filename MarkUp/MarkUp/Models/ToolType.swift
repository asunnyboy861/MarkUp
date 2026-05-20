import Foundation

enum ToolType: String, CaseIterable {
    case loupe
    case shape
    case arrow
    case text
    case pen
    case marker
    case pencil
    case highlight
    case blur
    case eraser

    var displayName: String {
        switch self {
        case .loupe: return "Loupe"
        case .shape: return "Shape"
        case .arrow: return "Arrow"
        case .text: return "Text"
        case .pen: return "Pen"
        case .marker: return "Marker"
        case .pencil: return "Pencil"
        case .highlight: return "Highlight"
        case .blur: return "Blur"
        case .eraser: return "Eraser"
        }
    }

    var systemImageName: String {
        switch self {
        case .loupe: return "magnifyingglass"
        case .shape: return "circle"
        case .arrow: return "arrow.right"
        case .text: return "textformat"
        case .pen: return "pencil.tip"
        case .marker: return "highlighter"
        case .pencil: return "pencil"
        case .highlight: return "paintbrush"
        case .blur: return "rectangle.dashed"
        case .eraser: return "eraser"
        }
    }

    var annotationType: AnnotationType? {
        switch self {
        case .loupe: return .loupe
        case .shape: return .shape
        case .arrow: return .arrow
        case .text: return .text
        case .pen, .marker, .pencil: return .drawing
        case .highlight: return .highlight
        case .blur: return .blur
        case .eraser: return nil
        }
    }

    var defaultLineWidth: CGFloat {
        switch self {
        case .loupe: return 2
        case .shape: return 2
        case .arrow: return 3
        case .text: return 1
        case .pen: return 2
        case .marker: return 8
        case .pencil: return 1
        case .highlight: return 16
        case .blur: return 20
        case .eraser: return 20
        }
    }

    var defaultOpacity: Double {
        switch self {
        case .highlight: return 0.4
        case .marker: return 0.6
        default: return 1.0
        }
    }
}
