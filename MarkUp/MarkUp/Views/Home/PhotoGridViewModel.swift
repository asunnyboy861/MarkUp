import Foundation
import Photos
import Combine

@MainActor
class PhotoGridViewModel: ObservableObject {
    @Published var photos: [PHAsset] = []
    @Published var isLoading = false

    private let imageService = ImageImportService()

    func loadPhotos(screenshotsOnly: Bool = false) async {
        isLoading = true
        if screenshotsOnly {
            photos = await imageService.fetchScreenshotAlbum()
        } else {
            photos = await imageService.fetchPhotos(limit: 100)
        }
        isLoading = false
    }
}
