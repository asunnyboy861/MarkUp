import Photos
import SwiftUI
import Combine

@MainActor
class ImageImportService: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined

    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        self.authorizationStatus = status
        return status == .authorized || status == .limited
    }

    private func ensureAuthorization() async -> Bool {
        if authorizationStatus == .authorized || authorizationStatus == .limited {
            return true
        }
        return await requestAuthorization()
    }

    func fetchPhotos(limit: Int = 50) async -> [PHAsset] {
        guard await ensureAuthorization() else { return [] }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = limit

        let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var assets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }

    func fetchScreenshotAlbum() async -> [PHAsset] {
        guard await ensureAuthorization() else { return [] }

        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumScreenshots,
            options: nil
        )

        var assets: [PHAsset] = []
        smartAlbums.enumerateObjects { collection, _, _ in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 50
            let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            result.enumerateObjects { asset, _, _ in
                assets.append(asset)
            }
        }
        return assets
    }

    func loadImage(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    func loadFullSizeImage(for asset: PHAsset) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.resizeMode = .exact

        let screenSize = UIScreen.main.bounds.size
        let pixelSize = CGSize(
            width: screenSize.width * UIScreen.main.scale,
            height: screenSize.height * UIScreen.main.scale
        )

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: pixelSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    func saveToPhotos(image: UIImage) async -> Bool {
        guard await ensureAuthorization() else { return false }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            return true
        } catch {
            return false
        }
    }
}
