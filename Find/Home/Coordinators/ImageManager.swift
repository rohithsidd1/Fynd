
import SwiftUI
import Combine

class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()

    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ShimmeringRectangle()
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let url = url else { return }

        // Check if the image is already cached
        if let cachedImage = ImageCacheManager.shared.getImage(forKey: url.absoluteString) {
            self.image = cachedImage
            return
        }

        // Download the image if not cached
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let downloadedImage = UIImage(data: data) else { return }
            
            // Cache the downloaded image
            ImageCacheManager.shared.setImage(downloadedImage, forKey: url.absoluteString)
            
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }.resume()
    }
}

struct ShimmeringRectangle: View {
    @State private var startPoint: UnitPoint = .topLeading
    @State private var endPoint: UnitPoint = .bottomTrailing

    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.6),
                        Color.gray.opacity(0.3)
                    ]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                .mask(Rectangle())
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    startPoint = .bottomTrailing
                    endPoint = .topLeading
                }
            }
    }
}
