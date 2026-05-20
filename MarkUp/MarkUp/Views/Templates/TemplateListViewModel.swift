import Foundation
import Combine

@MainActor
class TemplateListViewModel: ObservableObject {
    @Published var templates: [Template] = []
    private let templateService = TemplateService()

    init() {
        loadTemplates()
    }

    func loadTemplates() {
        templates = templateService.templates
    }

    func saveTemplate(name: String, annotations: [Annotation]) {
        templateService.saveTemplate(name: name, annotations: annotations)
        loadTemplates()
    }

    func deleteTemplate(_ template: Template) {
        templateService.deleteTemplate(template)
        loadTemplates()
    }
}
