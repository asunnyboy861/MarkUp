import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    let purchaseManager = PurchaseManager()

    @AppStorage("com.zzoutuo.MarkUp.rememberToolSettings") var rememberToolSettings = true
    @AppStorage("com.zzoutuo.MarkUp.highQualityExport") var highQualityExport = true

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
