import UIKit
import Photos

@MainActor
class ExportService {
    let imageImportService = ImageImportService()

    func export(annotations: [Annotation], image: UIImage, format: ExportFormat) -> Data? {
        switch format {
        case .png:
            let rendered = AnnotationRenderer.render(annotations: annotations, on: image)
            return rendered.pngData()
        case .jpg:
            let rendered = AnnotationRenderer.render(annotations: annotations, on: image)
            return rendered.jpegData(compressionQuality: 0.9)
        case .pdf:
            return AnnotationRenderer.renderPDF(annotations: annotations, on: image)
        }
    }

    func saveToPhotos(annotations: [Annotation], image: UIImage, format: ExportFormat) async -> Bool {
        guard format != .pdf else {
            guard let data = export(annotations: annotations, image: image, format: .pdf) else { return false }
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MarkUp_\(UUID().uuidString).pdf")
            do {
                try data.write(to: tempURL)
                let controller = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(controller, animated: true)
                }
                return true
            } catch {
                return false
            }
        }

        let rendered = AnnotationRenderer.render(annotations: annotations, on: image)
        return await imageImportService.saveToPhotos(image: rendered)
    }

    func share(annotations: [Annotation], image: UIImage, format: ExportFormat) -> (Data?, String) {
        let data = export(annotations: annotations, image: image, format: format)
        let fileName = "MarkUp_\(Int(Date().timeIntervalSince1970)).\(format.fileExtension)"
        return (data, fileName)
    }
}
