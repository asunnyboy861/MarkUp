import Foundation
import UIKit
import Combine

@MainActor
class BatchEditViewModel: ObservableObject {
    @Published var savedImages: [UIImage] = []

    func applyAnnotations(to image: UIImage) {
        savedImages.append(image)
    }
}
