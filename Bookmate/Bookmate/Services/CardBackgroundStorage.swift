import UIKit

enum CardBackgroundStorage {

    private static let directoryName = "CardBackgrounds"

    private static var directoryURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(directoryName)
    }

    static func save(_ image: UIImage, filename: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return false }
        let dir = directoryURL
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    }

    static func load(filename: String) -> UIImage? {
        let url = directoryURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func delete(filename: String) {
        let url = directoryURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
