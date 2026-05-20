import SwiftUI
import MessageUI

struct ContactSupportView: View {
    @State private var showMailComposer = false
    @State private var showMailAlert = false
    @State private var messageText = ""

    private let supportEmail = "iocompile67692@gmail.com"

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Contact Support")
                .font(.title2.weight(.semibold))

            Text("We'd love to hear from you. Send us an email and we'll get back to you as soon as possible.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 12) {
                Label(supportEmail, systemImage: "envelope")
                    .font(.subheadline)

                Label("MarkUp v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")", systemImage: "info.circle")
                    .font(.subheadline)

                Label("iOS \(UIDevice.current.systemVersion)", systemImage: "iphone")
                    .font(.subheadline)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            Spacer()

            Button {
                if MFMailComposeViewController.canSendMail() {
                    showMailComposer = true
                } else {
                    showMailAlert = true
                }
            } label: {
                Text("Send Email")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMailComposer) {
            MailComposerView(to: supportEmail)
        }
        .alert("Cannot Send Email", isPresented: $showMailAlert) {
            Button("Copy Email") {
                UIPasteboard.general.string = supportEmail
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please set up an email account on your device first, or copy our email address: \(supportEmail)")
        }
    }
}

struct MailComposerView: UIViewControllerRepresentable {
    let to: String

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.setToRecipients([to])
        composer.setSubject("MarkUp Support Request")
        composer.mailComposeDelegate = context.coordinator
        return composer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}
