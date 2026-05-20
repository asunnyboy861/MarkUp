import Foundation
import Combine

@MainActor
class TemplateService: ObservableObject {
    @Published var templates: [Template] = []

    private let defaults = UserDefaults.standard
    private let templatesKey = "com.zzoutuo.MarkUp.templates"

    init() {
        loadTemplates()
    }

    func saveTemplate(name: String, annotations: [Annotation]) {
        let template = Template(name: name, annotations: annotations)
        templates.append(template)
        persistTemplates()
    }

    func deleteTemplate(_ template: Template) {
        templates.removeAll { $0.id == template.id }
        persistTemplates()
    }

    func renameTemplate(_ template: Template, newName: String) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index].name = newName
            persistTemplates()
        }
    }

    private func loadTemplates() {
        if let data = defaults.data(forKey: templatesKey),
           let decoded = try? JSONDecoder().decode([Template].self, from: data) {
            self.templates = decoded
        }
    }

    private func persistTemplates() {
        if let data = try? JSONEncoder().encode(templates) {
            defaults.set(data, forKey: templatesKey)
        }
    }
}
