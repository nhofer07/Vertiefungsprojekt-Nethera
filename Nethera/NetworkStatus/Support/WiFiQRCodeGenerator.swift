import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

struct WiFiQRCodeGenerator {
    private let context = CIContext()

    func makeQRCode(ssid: String, password: String, encryption: String) -> UIImage? {
        let wifiString = "WIFI:T:\(escape(encryption));S:\(escape(ssid));P:\(escape(password));;"
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(wifiString.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 12, y: 12))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private func escape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: ":", with: "\\:")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}
