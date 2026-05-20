import Foundation

enum ExportFormat: String, CaseIterable {
    case png
    case jpg
    case pdf

    var displayName: String {
        switch self {
        case .png: return "PNG"
        case .jpg: return "JPEG"
        case .pdf: return "PDF"
        }
    }

    var fileExtension: String {
        switch self {
        case .png: return "png"
        case .jpg: return "jpg"
        case .pdf: return "pdf"
        }
    }

    var utType: String {
        switch self {
        case .png: return "public.png"
        case .jpg: return "public.jpeg"
        case .pdf: return "com.adobe.pdf"
        }
    }
}
