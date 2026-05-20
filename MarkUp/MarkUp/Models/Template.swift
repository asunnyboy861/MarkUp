import Foundation

struct Template: Identifiable, Codable {
    let id: UUID
    var name: String
    var annotations: [Annotation]
    var createdAt: Date
    var thumbnailData: Data?

    init(name: String, annotations: [Annotation], thumbnailData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.annotations = annotations
        self.createdAt = Date()
        self.thumbnailData = thumbnailData
    }
}
